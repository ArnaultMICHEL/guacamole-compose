#!/bin/bash

source $(dirname $0)/../../.load.env

source $(dirname $0)/../../.shared_cli_functions.sh

GUACAMOLE_ADMIN_PASSWORD=
# # Configure truststore for TLS server authentication
kcadm.sh config truststore --trustpass ${KC_TLS_TRUSTSTORE_PWD} ${KC_TLS_TRUSTSTORE}

authentication4KeycloakAdminCLI master "${KEYCLOAK_ADMIN_USER}" "${KEYCLOAK_ADMIN_PASSWORD}"


# # Authentication
# kcadm.sh config credentials \
#   --server https://${KC_HOSTNAME} --realm master \
#   --user ${KEYCLOAK_ADMIN_USER} --password ${KEYCLOAK_ADMIN_PASSWORD}

## Find the existing guacadmin user in keycloak
KC_GUACAMOLE_ADMIN_UUID=$(kcadm.sh get users -r ${KEYCLOAK_REALM_NAME} -q username=guacadmin@guacadmin |jq -r '.[].id')
echo " Keycloak's Guacamole account UUID  : ${KC_GUACAMOLE_ADMIN_UUID}"

## Delete account if it exists
if  [[ ! -z "${KC_GUACAMOLE_ADMIN_UUID}" ]]
then
  kcadm.sh delete users/${KC_GUACAMOLE_ADMIN_UUID} -r ${KEYCLOAK_REALM_NAME}
fi

#### Add the guacadmin user to keycloak with an email
kcadm.sh create users \
  -s username=guacadmin@guacadmin \
  -s enabled=true \
  -s email=guacadmin@guacadmin \
  -s emailVerified=true \
  -r ${KEYCLOAK_REALM_NAME}

# Set the password to default, must be changed on first login
kcadm.sh set-password \
  --username guacadmin@guacadmin \
  --new-password guacAdmin@guacAdmin \
  --temporary \
  -r ${KEYCLOAK_REALM_NAME}

# Make guacadmin an admin of the realm
kcadm.sh add-roles \
  --uusername guacadmin@guacadmin \
  --cclientid realm-management \
  --rolename realm-admin \
  -r ${KEYCLOAK_REALM_NAME}
  
kcadm.sh add-roles \
  --uusername guacadmin@guacadmin \
  --cclientid guacamole \
  --rolename Guacamole-Admins \
  -r ${KEYCLOAK_REALM_NAME}
