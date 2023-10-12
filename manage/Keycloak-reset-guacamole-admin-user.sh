#!/bin/bash

source $(dirname $0)/../../.load.env

source $(dirname $0)/../../.shared_cli_functions.sh

# # Configure truststore for TLS server authentication
kcadm.sh config truststore --trustpass ${KC_TLS_TRUSTSTORE_PWD} ${KC_TLS_TRUSTSTORE}

authentication4KeycloakAdminCLI master "${KEYCLOAK_ADMIN_USER}" "${KEYCLOAK_ADMIN_PASSWORD}"


# # Authentication
# kcadm.sh config credentials \
#   --server https://${KC_HOSTNAME} --realm master \
#   --user ${KEYCLOAK_ADMIN_USER} --password ${KEYCLOAK_ADMIN_PASSWORD}

## Find the existing guacadmin user in keycloak
KC_GUACAMOLE_ADMIN_UUID=$(kcadm.sh get users -r ${KEYCLOAK_REALM_NAME} -q username=${GUACAMOLE_ADMIN_USER} |jq -r '.[].id')
echo " Keycloak's Guacamole account UUID  : ${KC_GUACAMOLE_ADMIN_UUID}"

## Delete account if it exists
if  [[ ! -z "${KC_GUACAMOLE_ADMIN_UUID}" ]]
then
  kcadm.sh delete users/${KC_GUACAMOLE_ADMIN_UUID} -r ${KEYCLOAK_REALM_NAME}
fi

#### Add the guacadmin user to keycloak with an email
kcadm.sh create users \
  -s username=${GUACAMOLE_ADMIN_USER} \
  -s enabled=true \
  -s email=guacadmin@guacadmin.local \
  -s emailVerified=true \
  -r ${KEYCLOAK_REALM_NAME}

# Set the password to default, must be changed on first login
kcadm.sh set-password \
  --username ${GUACAMOLE_ADMIN_USER} \
  --new-password ${GUACAMOLE_ADMIN_TEMP_PASSWORD} \
  --temporary \
  -r ${KEYCLOAK_REALM_NAME}

# Grant guacadmin as an admin of the dedicated realm
kcadm.sh add-roles \
  --username ${GUACAMOLE_ADMIN_USER} \
  --cclientid realm-management \
  --rolename realm-admin \
  -r ${KEYCLOAK_REALM_NAME}

# Grant guacadmin as an admin of guacamole webapp
kcadm.sh add-roles \
  --username ${GUACAMOLE_ADMIN_USER} \
  --cclientid guacamole \
  --rolename Guacamole-Admins \
  -r ${KEYCLOAK_REALM_NAME}
