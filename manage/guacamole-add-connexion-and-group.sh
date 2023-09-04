#!/bin/bash

source $(dirname $0)/../.secrets.env
source $(dirname $0)/../.shared_cli_functions.sh

# check CLI parameters
[[ $1 == "" ]] || [[ $2 == "" ]] && {
    echo "usage : $0 <hostname> <group> <user> <password>"
    exit 1
}

NONCE=$(openssl rand -base64 16 | tr -d '=')

# Keycloak authentication
KC_TOKENS=$(curl --silent -X POST "https://${KC_HOSTNAME}/realms/${KEYCLOAK_REALM_NAME}/protocol/openid-connect/token" \
  --insecure \
  -d "username=${GUACAMOLE_ADMIN_USER}" \
  -d "password=${GUACAMOLE_ADMIN_PASSWORD}" \
  -d 'grant_type=password' \
  -d 'response_type=id_token' \
  -d 'scope=openid+email+profile' \
  -d "redirect_uri=https%3A%2F%2F${GUAC_HOSTNAME}%2Fguacamole" \
  -d "nonce=${NONCE}" \
  -d "client_id=guacamole")
testRC

#extracting Keycloak ID Token 
echo ${KC_TOKENS} |jq
ACCESS_TOKEN=$(echo ${KC_TOKENS} |jq -r '.access_token')
ID_TOKEN=$(echo ${KC_TOKENS} |jq -r '.id_token')
#echo "access : ${ACCESS_TOKEN}"
echo "ID token : "
echo ${ID_TOKEN} | jq -R 'split(".") | .[0],.[1] | @base64d | fromjson'


# Fails Here : id token doesn't have nonce claim embedded 

curl -X POST "https://${GUAC_HOSTNAME}/guacamole/api/tokens" \
     --insecure --silent\
     --header "Content-Type: application/x-www-form-urlencoded" \
     -d "id_token=${ID_TOKEN}" \

# direct authentication [ with guacadmin local account ] is not working : ()

# Create RDP connection
# https://github.com/ridvanaltun/guacamole-rest-api-documentation/blob/master/docs/CONNECTIONS.md#create-rdp-connection
#curl -X POST https://${GUAC_HOSTNAME}/guacamole/api/tokens
#     --header "Guacamole-Token: ${GUAC_TOKEN}" \
#     --silent --insecure \
#     

# Create an SSH connexion
# https://github.com/ridvanaltun/guacamole-rest-api-documentation/blob/master/docs/CONNECTIONS.md#create-ssh-connection

# Create a user group
# https://github.com/ridvanaltun/guacamole-rest-api-documentation/blob/master/docs/USER-GROUPS.md#create-user-group
