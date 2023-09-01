#!/bin/bash

#Loading global env var
source $(dirname $0)/../../.secrets.env

# Keycloak terraform plugin conf
export KEYCLOAK_URL=https://${KC_HOSTNAME}
export KEYCLOAK_CLIENT_TIMEOUT=10
export KEYCLOAK_BASE_PATH=
export KEYCLOAK_USER=${KEYCLOAK_ADMIN_USER}
export KEYCLOAK_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}
export KEYCLOAK_CLIENT_ID="admin-cli"
export TF_VAR_keycloak_realm=${KEYCLOAK_REALM_NAME}
export TF_VAR_root_ca_cert=$(dirname $0)/../../init/x509/${GUAC_HOSTNAME}_ecc/ca.cer

export TF_VAR_guacamole_openid_callback=https://${GUAC_HOSTNAME}/guacamole
export TF_VAR_guacamole_root_url=https://${GUAC_HOSTNAME}/guacamole
export TF_VAR_guacamole_web_origins=https://${GUAC_HOSTNAME}


#Downloading terraform binary
TERRAFORM_VERSION="1.4.5"

[[ ! -d "$HOME/.local/bin" ]] && mkdir -p $HOME/.local/bin
[[ ! -e "$HOME/.local/bin/terraform" ]] && {
  echo " => installing terraform"
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform.zip
  unzip /tmp/terraform.zip -d $HOME/.local/bin
  rm /tmp/terraform.zip
}
export PATH=${PATH}:$HOME/.local/bin

# apply
terraform -chdir=$(dirname $0)/guacamole-realm-config init
terraform -chdir=$(dirname $0)/guacamole-realm-config apply

#terraform -chdir=$(dirname $0)/guacamole-realm-config destroy