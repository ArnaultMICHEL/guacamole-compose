#!/bin/bash

source $(dirname $0)/../../.secrets.env

# Install Keycloak CLI standalone client
[ ! -d keycloak-client-tools  ] && (
  wget https://repo1.maven.org/maven2/org/keycloak/keycloak-client-cli-dist/${KEYCLOAK_VERSION}/keycloak-client-cli-dist-${KEYCLOAK_VERSION}.zip
  unzip keycloak-client-cli-dist-${KEYCLOAK_VERSION}.zip
  chmod +x keycloak-client-tools/bin/kcadm.sh
  rm keycloak-client-cli-dist-${KEYCLOAK_VERSION}.zip
)
export PATH=${PATH}:$(dirname $0)/keycloak-client-tools/bin/

# Configure truststore for TLS server authentication
kcadm.sh config truststore --trustpass ${KC_TLS_TRUSTSTORE_PWD} ${KC_TLS_TRUSTSTORE}

# Authentication
kcadm.sh config credentials \
  --server https://${KC_HOSTNAME} --realm master \
  --user ${KEYCLOAK_ADMIN_USER} --password ${KEYCLOAK_ADMIN_PASSWORD}

## Create the guacadmin user in keycloak
#### Add the guacadmin user to keycloak with an email
kcadm.sh \
  create users \
  -s username=guacadmin@guacadmin \
  -s enabled=true \
  -s email=guacadmin@guacadmin \
  -r ${KEYCLOAK_REALM_NAME}

# Set the password, must be changed on first login
kcadm.sh \
  set-password \
  --username guacadmin@guacadmin \
  --new-password guacAdmin@guacAdmin \
  --temporary \
  -r ${KEYCLOAK_REALM_NAME}

# Make guacadmin an admin of the realm
kcadm.sh \
  add-roles \
  --uusername guacadmin@guacadmin \
  --cclientid realm-management \
  --rolename realm-admin \
  -r ${KEYCLOAK_REALM_NAME}
