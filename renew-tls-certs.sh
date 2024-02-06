#!/bin/bash

# Renew private keys & certificates for Guacamole & Keycloak

source .load.env 


if [[ "${TLS_LETS_ENCRYPT}" == "true" ]]
then
  
  echo -e "\n Generating let's encrypt certificates"
  
  echo -e "\n Generating a new TLS server certificate for ${GUAC_HOSTNAME}" 
  docker run --rm  -it  \
    -v "$(pwd)/init/x509":/acme.sh  \
    --net=host \
    neilpang/acme.sh --renew -d ${GUAC_HOSTNAME} --standalone

  echo -e "\n Generating a new TLS server certificate for  ${KC_HOSTNAME}"
  docker run --rm  -it  \
    -v "$(pwd)/init/x509":/acme.sh  \
    --net=host \
    neilpang/acme.sh --renew -d ${KC_HOSTNAME} --standalone

  #TODO : better fix for unix rights
  cp init/x509/${GUAC_HOSTNAME}_ecc/${GUAC_HOSTNAME}.cer init/guacamole.crt
  cp init/x509/${KC_HOSTNAME}_ecc/${KC_HOSTNAME}.cer init/keycloak.crt
  sudo cp init/x509/${GUAC_HOSTNAME}_ecc/${GUAC_HOSTNAME}.key init/guacamole.key
  sudo cp init/x509/${KC_HOSTNAME}_ecc/${KC_HOSTNAME}.key init/keycloak.key
  sudo chmod a+r init/guacamole.key init/keycloak.key

else

  # keep a copy of existing keys & certs
  rm init/{guacamole,keycloak}.{key,crt}.old 
  mv init/guacamole.key init/guacamole.key.old
  mv init/guacamole.crt init/guacamole.crt.old
  mv init/keycloak.key  init/keycloak.key.old
  mv init/keycloak.crt  init/keycloak.crt.old

  echo -e "\n Renewing TLS Server Keys and certificates for Guacamole"
  openssl req \
    -newkey rsa:2048 \
    -nodes \
    -keyout init/guacamole.key \
    -x509 \
    -days 730 \
    -out init/guacamole.crt \
    -subj "/C=FR/O=My Company/OU=My Division/CN=${GUAC_HOSTNAME}"

  echo -e "\n Renewing TLS Server Keys and certificates for Keycloak"
  # values pulled from server.xml within the image, and errors from the docker log
  openssl req \
    -newkey rsa:2048 \
    -nodes \
    -keyout init/keycloak.key \
    -x509 \
    -days 730 \
    -out init/keycloak.crt \
    -subj "/C=FR/O=My Company/OU=My Division/CN=${KC_HOSTNAME}"

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

#finally restart 
docker compose down
docker compose up -d
