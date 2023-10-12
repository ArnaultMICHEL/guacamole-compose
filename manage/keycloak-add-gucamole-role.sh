#!/bin/bash

source $(dirname $0)/../.load.env
source $(dirname $0)/../.shared_cli_functions.sh

use_kcadm

# check CLI parameters
[[ $1 == "" ]] && {
    echo "usage : $0 <client-role-name> [role-description]"
    exit 1
}

title "Add Keycloak role for guacamole" "Adding a client role for guacamole ( corresponding to guacamole user's Group)"

authentication4KeycloakAdminCLI "${KEYCLOAK_REALM_NAME}" "${GUACAMOLE_ADMIN_USER}" "${GUACAMOLE_ADMIN_TEMP_PASSWORD}"

echo "Adding new Guacamole client roles : $1"
KC_GUACAMOLE_CLIENT_UUID=$(kcadm.sh get clients \
  -r ${KEYCLOAK_REALM_NAME} --fields id,clientId | jq -r ".[] |select (.clientId == \"guacamole\") | .id")
kcadm.sh create clients/${KC_GUACAMOLE_CLIENT_UUID}/roles -r "${KEYCLOAK_REALM_NAME}" -s "name=$1" -s "description=$2"


echo "List of all Guacamole client roles : "
kcadm.sh get-roles -r ${KEYCLOAK_REALM_NAME} --cclientid guacamole |jq -r '.[].name'

