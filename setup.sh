#!/bin/bash -x

source .env 

echo "checking for patch"
patch -v
echo "checking for wget"
wget -v
echo "checking for docker-compose"
docker-compose -v
echo "checking for docker"
docker -v
echo "checking for keytool"
keytool -v

# create directories
mkdir -p {data/guacamole,data/keycloak,init,openid} 

cd openid

echo " Downloading Guacamole OpenID auth plugin"
wget https://dlcdn.apache.org/guacamole/1.5.3/binary/guacamole-auth-sso-1.5.3.tar.gz
tar -xvzf guacamole-auth-sso-1.5.3.tar.gz
mv guacamole-auth-sso-1.5.3/openid/* .
rm guacamole-auth-sso-1.5.3.tar.gz guacamole-auth-sso-1.5.3 -rf
cd ..

echo " Generating guacamole SQL DB init script"
# create the database initialization script for the guacamole database
docker run --rm \
  docker.io/guacamole/guacamole:1.5.3 \
    /opt/guacamole/bin/initdb.sh --postgres > init/initdb.sql.orig

cp init/initdb.sql.orig init/initdb.sql

patch init/initdb.sql < config/guacamole/1.add-guacadmin-email.patch

# get the original server.xml
touch init/server.xml.orig
docker run --rm --name guacamole-setup \
  docker.io/guacamole/guacamole:1.1.0 \
  cat /usr/local/tomcat/conf/server.xml > init/server.xml.orig

# make a copy to patch
cp init/server.xml.orig init/server.xml

# enable ssl, and such
patch init/server.xml < config/guacamole/0.enable-tomcat-ssl.patch

# Need self-signed cert for ca

# Create private keys for:
#   Guacamole
#   Keycloak

openssl req \
  -newkey rsa:2048 \
  -nodes \
  -keyout init/guacamole.key \
  -x509 \
  -days 365 \
  -out init/guacamole.crt \
  -subj "/C=US/ST=CA/L=Anytown/O=Ridgecrest First Aid/OU=AED Instructors/CN=${GUAC_HOSTNAME}"

# values pulled from server.xml within the image, and errors from the docker log
keytool -genkey \
  -alias server \
  -keyalg RSA \
  -keystore init/application.keystore \
  -keysize 2048 \
  -storepass password \
  -dname "cn=${KC_HOSTNAME}, ou=AED Instructors, o=Ridgecrest, c=US" \
  -keypass password \
  -trustcacerts \
  -validity 365

# make the certificate available to guacamole
touch init/keycloak.crt
keytool -exportcert \
  -keystore init/application.keystore \
  -alias server \
  -storepass password \
  -keypass password | \
  openssl x509 -inform der -text > init/keycloak.crt

# Grabbing cacerts, don't use this for standalone.xml
# as we don't link to postgres
touch init/cacerts
timeout 10 docker run --rm --name keycloak-cacerts \
  docker.io/keycloak/keycloak:22.0.1 &
sleep 1s
docker cp keycloak-cacerts:/etc/pki/ca-trust/extracted/java/cacerts init/cacerts

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

