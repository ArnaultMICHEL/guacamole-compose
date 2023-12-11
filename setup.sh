#!/bin/bash 

source .load.env 

## Functions
############

check_tools() {
  echo "checking for patch"
  [[ -x "$(command -v patch)" ]] || { echo " patch not found => installing it"; sudo dnf install patch -y; }

  echo "checking for wget"
  [[ -x "$(command -v wget)" ]] || { echo " wget not found => installing it"; sudo dnf install wget -y; }

  echo "checking for docker"
  [[ -x "$(command -v docker)" ]] || {
    echo " wget not found => installing it";
    sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo;
    sudo dnf install docker-ce docker-compose-plugin -y;
    sudo systemctl start docker;
    sudo systemctl enable docker;
  }

  echo "checking for keytool"
  [[ -x "$(command -v keytool)" ]] || { echo " keytool not found => installing openjdk"; sudo dnf install java-17-openjdk.x86_64 -y; }

}

guacamole_init() {

  # create directories
  mkdir -p {data/guacamole,data/keycloak,init,openid,tools} 

  [[ ! -e openid/guacamole-auth-sso-openid-${GUACAMOLE_VERSION}.jar ]] && {
    cd openid
    echo -e "\n Downloading Guacamole OpenID auth plugin"
    wget --quiet https://dlcdn.apache.org/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-sso-${GUACAMOLE_VERSION}.tar.gz
    tar xvzf guacamole-auth-sso-${GUACAMOLE_VERSION}.tar.gz
    mv guacamole-auth-sso-${GUACAMOLE_VERSION}/openid/* .
    rm guacamole-auth-sso-${GUACAMOLE_VERSION}.tar.gz guacamole-auth-sso-${GUACAMOLE_VERSION} -rf
    cd ..
  }

  echo -e "\n Generating guacamole SQL DB init script"
  # create the database initialization script for the guacamole database
  docker run --rm \
    docker.io/guacamole/guacamole:${GUACAMOLE_VERSION} \
      /opt/guacamole/bin/initdb.sh --postgresql > init/initdb.sql.orig

  cp init/initdb.sql.orig init/initdb.sql

  patch init/initdb.sql < config/guacamole/1.add-guacadmin-email.patch


  echo -e "\n Activate TLS on Tomcat server"
  # get the original server.xml
  touch init/server.xml.orig
  docker run --rm --name guacamole-setup \
    docker.io/guacamole/guacamole:${GUACAMOLE_VERSION} \
    cat /usr/local/tomcat/conf/server.xml > init/server.xml.orig

  # make a copy to patch
  cp init/server.xml.orig init/server.xml

  # enable ssl, and such
  patch init/server.xml < config/guacamole/0.enable-tomcat-ssl.patch

}

keycloak_init() {

  #Managing truststore
  [[ ! -e init/cacerts ]] && {

    echo -e "\n Getting Java Truststore from keycloak image"

    #increase timeout and sleep timers if you have a slow connexion
    docker pull docker.io/keycloak/keycloak:${KEYCLOAK_VERSION}
    timeout 30 docker run --rm --name keycloak-cacerts \
      docker.io/keycloak/keycloak:${KEYCLOAK_VERSION} start &
    sleep 15

    docker cp keycloak-cacerts:/etc/pki/ca-trust/extracted/java/cacerts init/cacerts
    chmod +w init/cacerts
    
    docker stop keycloak-cacerts
    docker rm keycloak-cacerts

    for ca_file in  $(ls trustedCAs)
    do
      #check if this file is a real X.509 certificate
      openssl x509 -in trustedCAs/${ca_file} -text -noout >/dev/null 2>&1 && (
        echo -e "\n Adding private CA file ${ca_file} with alias ${ca_file%.*} for mutual TLS with Keycloak"
        keytool -importcert \
          -alias ${ca_file%.*} \
          -keystore init/cacerts \
          -storepass changeit \
          -file trustedCAs/${ca_file} \
          -trustcacerts -noprompt
      ) || echo  -e "\n skipping ${ca_file} as its not a X.509 certificate (PEM format)"
    done
  }

}

tls_init() {
  # Create private keys for:
  #   Guacamole
  #   Keycloak
  if [[ "${TLS_LETS_ENCRYPT}" == "true" ]]
  then
    echo -e "\n Generating let's encrypt certificates"
    [[ ! -d init/x509 ]] && mkdir init/x509

    #registering if first time
    [[ ! -e init/x509/account.conf ]] && \
        docker run --rm  -it  \
          -v "$(pwd)/init/x509":/acme.sh  \
          --net=host \
          neilpang/acme.sh  --register-account -m ${ACME_ACCOUNT_EMAIL}
    
    #issue 2 self signed server certificate (HA Proxy needs two different certificates for LB) if certificate files does not exists
    [[ ! -e init/x509/${GUAC_HOSTNAME}_ecc/${GUAC_HOSTNAME}.cer ]] && {
      echo -e "\n Generating a new TLS server certificate"
      docker run --rm  -it  \
        -v "$(pwd)/init/x509":/acme.sh  \
        --net=host \
        neilpang/acme.sh --issue -d ${GUAC_HOSTNAME} --standalone
    }
    [[ ! -e init/x509/${KC_HOSTNAME}_ecc/${KC_HOSTNAME}.cer ]] && {
      echo -e "\n Generating a new TLS server certificate"
      docker run --rm  -it  \
        -v "$(pwd)/init/x509":/acme.sh  \
        --net=host \
        neilpang/acme.sh --issue -d ${KC_HOSTNAME} --standalone
    }
    #TODO : better fix for unix rights
    cp init/x509/${GUAC_HOSTNAME}_ecc/${GUAC_HOSTNAME}.cer init/guacamole.crt
    cp init/x509/${KC_HOSTNAME}_ecc/${KC_HOSTNAME}.cer init/keycloak.crt
    sudo cp init/x509/${GUAC_HOSTNAME}_ecc/${GUAC_HOSTNAME}.key init/guacamole.key
    sudo cp init/x509/${KC_HOSTNAME}_ecc/${KC_HOSTNAME}.key init/keycloak.key
    chmod a+r init/guacamole.key init/keycloak.key
    
    echo -e "\n Adding  CA for Keycloak client kcadm.sh"
    keytool -importcert \
      -alias ACMECA \
      -keystore init/cacerts \
      -storepass changeit \
      -file init/x509/${GUAC_HOSTNAME}_ecc/ca.cer \
      -trustcacerts -noprompt

  else
    [[ ! -e init/guacamole.key ]] && {
      echo -e "\n Generate TLS Server Keys and certificates for Guacamole"
      openssl req \
        -newkey rsa:2048 \
        -nodes \
        -keyout init/guacamole.key \
        -x509 \
        -days 730 \
        -out init/guacamole.crt \
        -subj "/C=FR/O=My Company/OU=My Division/CN=${GUAC_HOSTNAME}"
    }


    [[ ! -e init/keycloak.key ]] && {
      echo -e "\n Generate TLS Server Keys and certificates for Keycloak"
      # values pulled from server.xml within the image, and errors from the docker log
      openssl req \
        -newkey rsa:2048 \
        -nodes \
        -keyout init/keycloak.key \
        -x509 \
        -days 730 \
        -out init/keycloak.crt \
        -subj "/C=FR/O=My Company/OU=My Division/CN=${KC_HOSTNAME}"
    }

    #TODO : better fix for unix rights
    sudo chmod a+r init/guacamole.key init/keycloak.key

    #adding self signed certificates to truststore
    chmod u+w init/cacerts

    keytool -importcert \
      -alias keycloak \
      -keystore init/cacerts \
      -storepass changeit \
      -file init/keycloak.crt \
      -trustcacerts -noprompt

    keytool -importcert \
      -alias guacamole \
      -keystore init/cacerts \
      -storepass changeit \
      -file init/guacamole.crt \
      -trustcacerts -noprompt

  fi

}

ha_proxy_conf() {

  echo -e "\n Modifying HAProxy configuration file with FQDN"
  sed -i -e "s|use_backend bk_guacamole.*|use_backend bk_guacamole if { req_ssl_sni -i ${GUAC_HOSTNAME} }|g"   \
        -e "s|use_backend bk_keycloak .*|use_backend bk_keycloak  if { req_ssl_sni -i ${KC_HOSTNAME} }|g" \
      config/haproxy/haproxy.cfg
      
}

# Main

check_tools

guacamole_init

keycloak_init

tls_init

ha_proxy_conf