#!/bin/bash

source $(dirname $0)/../../.secrets.env

# install Keycloak client
[ ! -d keycloak-client-tools  ] && (
  wget https://repo1.maven.org/maven2/org/keycloak/keycloak-client-cli-dist/${KEYCLOAK_VERSION}/keycloak-client-cli-dist-${KEYCLOAK_VERSION}.zip
  unzip keycloak-client-cli-dist-${KEYCLOAK_VERSION}.zip
  chmod +x keycloak-client-tools/bin/kcadm.sh
  rm keycloak-client-cli-dist-${KEYCLOAK_VERSION}.zip
)
export PATH=${PATH}:$(dirname $0)/keycloak-client-tools/bin/

#add keyclock certificate to dedicated truststore
export KC_OPTS="-Djsse.enableSNIExtension=true \
                -Djavax.net.ssl.trustStoreType=jks \
                -Djavax.net.ssl.trustStore=${KC_TLS_TRUSTSTORE} \
                -Djavax.net.ssl.trustStorePassword=${KC_TLS_TRUSTSTORE_PWD}  \
                -Djavax.net.debug=none"

## Create the guacadmin user in keycloak
#### Add the guacadmin user to keycloak with an email
kcadm.sh \
  create users \
  -s username=guacadmin@guacadmin \
  -s enabled=true \
  -s email=guacadmin@guacadmin \
  -r master \
  --server https://${KC_HOSTNAME}/ \
  --realm master \
  --user ${KEYCLOAK_ADMIN_USER} \
  --password  ${KEYCLOAK_ADMIN_PASSWORD}

# Set the password
kcadm.sh \
  set-password \
  --username guacadmin@guacadmin \
  --new-password guacadmin \
  -r master \
  --server https://${KC_HOSTNAME}/ \
  --realm master \
  --user ${KEYCLOAK_ADMIN_USER} \
  --password  ${KEYCLOAK_ADMIN_PASSWORD}

# Make guacadmin an admin
#kcadm.sh \
#  add-roles \
#  --uusername guacadmin@guacadmin \
#  --rolename admin \
#  -r master \
#  --server https://${KC_HOSTNAME}/ \
#  --realm master \
#  --user ${KEYCLOAK_ADMIN_USER} \
#  --password  ${KEYCLOAK_ADMIN_PASSWORD}

### Add the guacamole-client
kcadm.sh \
  create clients \
  --file guacamole-client.json \
  -r master \
  --server https://${KC_HOSTNAME}/ \
  --realm master \
  --user ${KEYCLOAK_ADMIN_USER} \
  --password  ${KEYCLOAK_ADMIN_PASSWORD}
