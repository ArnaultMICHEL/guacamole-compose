#!/bin/bash 

source .secrets.env 

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

echo ""

# create directories
mkdir -p {data/guacamole,data/keycloak,init,openid} 

[[ ! -e openid/guacamole-auth-sso-openid-1.5.3.jar ]] && {
  cd openid
  echo -e "\ Downloading Guacamole OpenID auth plugin"
  wget https://dlcdn.apache.org/guacamole/1.5.3/binary/guacamole-auth-sso-1.5.3.tar.gz
  tar xvzf guacamole-auth-sso-1.5.3.tar.gz
  mv guacamole-auth-sso-1.5.3/openid/* .
  rm guacamole-auth-sso-1.5.3.tar.gz guacamole-auth-sso-1.5.3 -rf
  cd ..
}

echo -e "\n Generating guacamole SQL DB init script"
# create the database initialization script for the guacamole database
docker run --rm \
  docker.io/guacamole/guacamole:1.5.3 \
    /opt/guacamole/bin/initdb.sh --postgresql > init/initdb.sql.orig

cp init/initdb.sql.orig init/initdb.sql

patch init/initdb.sql < config/guacamole/1.add-guacadmin-email.patch

echo -e "\n Activate TLS on Tomcat server"
# get the original server.xml
touch init/server.xml.orig
docker run --rm --name guacamole-setup \
  docker.io/guacamole/guacamole:1.5.3 \
  cat /usr/local/tomcat/conf/server.xml > init/server.xml.orig

# make a copy to patch
cp init/server.xml.orig init/server.xml

# enable ssl, and such
patch init/server.xml < config/guacamole/0.enable-tomcat-ssl.patch

# Need self-signed cert for ca

# Create private keys for:
#   Guacamole
#   Keycloak

echo -e "\n Generate TLS Server Keys and certificates for Guacamole and Keycloak"
openssl req \
  -newkey rsa:2048 \
  -nodes \
  -keyout init/guacamole.key \
  -x509 \
  -days 730 \
  -out init/guacamole.crt \
  -subj "/C=FR/O=My Company/OU=My Division/CN=${GUAC_HOSTNAME}"

# values pulled from server.xml within the image, and errors from the docker log
keytool -genkey \
  -alias server \
  -keyalg RSA \
  -keystore init/application.keystore \
  -keysize 2048 \
  -storepass ${JKS_STOREPASS} \
  -dname "cn=${KC_HOSTNAME}, ou=My Division, o=My Company, c=FR" \
  -keypass ${JKS_STOREPASS} \
  -trustcacerts \
  -validity 720

# make the certificate available to guacamole
touch init/keycloak.crt
keytool -exportcert \
  -keystore init/application.keystore \
  -alias server \
  -storepass ${JKS_STOREPASS} \
  -keypass ${JKS_STOREPASS} -rfc > init/keycloak.crt

# Grabbing cacerts, don't use this for standalone.xml
# as we don't link to postgres
touch init/cacerts
timeout 10 docker run --rm --name keycloak-cacerts \
  docker.io/keycloak/keycloak:22.0.1 start &
sleep 2s
docker cp keycloak-cacerts:/etc/pki/ca-trust/extracted/java/cacerts init/cacerts

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

docker stop keycloak-cacerts
docker rm keycloak-cacerts

