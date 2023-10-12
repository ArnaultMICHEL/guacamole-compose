#!/bin/bash

#Loading global env var
source $(dirname $0)/../../.load.env

source $(dirname $0)/../../.shared_cli_functions.sh

check_terraform_binary

# Keycloak terraform plugin config
export KEYCLOAK_URL=https://${KC_HOSTNAME}
export KEYCLOAK_CLIENT_TIMEOUT=10
export KEYCLOAK_BASE_PATH=
export KEYCLOAK_USER=${KEYCLOAK_ADMIN_USER}
export KEYCLOAK_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}
export KEYCLOAK_CLIENT_ID="admin-cli"

export TF_VAR_keycloak_realm=${KEYCLOAK_REALM_NAME}
export TF_VAR_root_ca_cert=$(dirname $0)/../../init/x509/${GUAC_HOSTNAME}_ecc/ca.cer

# Keycloak guacamole realm config
export TF_VAR_guacamole_openid_callback=https://${GUAC_HOSTNAME}/
export TF_VAR_guacamole_root_url=https://${GUAC_HOSTNAME}/
export TF_VAR_guacamole_web_origins=https://${GUAC_HOSTNAME}
export TF_VAR_guacamole_admin_login=${GUACAMOLE_ADMIN_USER}
export TF_VAR_guacamole_admin_password=${GUACAMOLE_ADMIN_TEMP_PASSWORD}

terraform -chdir=$(dirname $0)/guacamole-realm-config init

terraform -chdir=$(dirname $0)/guacamole-realm-config apply

#terraform -chdir=$(dirname $0)/guacamole-realm-config destroy