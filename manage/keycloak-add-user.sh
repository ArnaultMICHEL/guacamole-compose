#!/bin/bash

source $(dirname $0)/../.secrets.env
source $(dirname $0)/../.shared_cli_functions.sh

use_kcadm

TMP_PWD=$(openssl rand -base64 10 | tr -d '=')

# check CLI parameters
[[ $1 == "" ]] || [[ $2 == "" ]] && {
    echo "usage : $0 <username> <email>"
    exit 1
}

title "Add Keycloak User for guacamole" "Adding a user to keycloak with a temporary password and guacamole roles"

authentication4KeycloakAdminCLI "${KEYCLOAK_REALM_NAME}" "${GUACAMOLE_ADMIN_USER}" "${GUACAMOLE_ADMIN_PASSWORD}"

## Create the user in keycloak
kcadm.sh \
  create users \
  -s username=$1 \
  -s enabled=true \
  -s email=$2 \
  -s emailVerified=true \
  -r ${KEYCLOAK_REALM_NAME}

# Set the temporary password, must be changed on first login
kcadm.sh \
  set-password \
  --username $1 \
  --new-password ${TMP_PWD} \
  --temporary \
  -r ${KEYCLOAK_REALM_NAME}

echo "User $1 is created with temporary password ${TMP_PWD}"


echo "Select one or more guacamole roles to add to the user"
Guacamole_Client_Role_List=( $(kcadm.sh get-roles -r ${KEYCLOAK_REALM_NAME} --cclientid guacamole |jq -r '.[].name') )
select client_role in "${Guacamole_Client_Role_List[@]}" "quit"
do
    case ${client_role} in
        "quit")
            exit 1;;
        *)
            kcadm.sh add-roles \
                --uusername $1 \
                --cclientid guacamole \
                --rolename ${client_role} \
                -r ${KEYCLOAK_REALM_NAME}
            #break;;
    esac
done