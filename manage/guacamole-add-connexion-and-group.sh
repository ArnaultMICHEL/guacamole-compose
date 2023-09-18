#!/bin/bash

source $(dirname $0)/../.secrets.env
source $(dirname $0)/../.shared_cli_functions.sh

# check CLI parameters
[[ $1 == "" ]] || [[ $2 == "" ]] && {
    echo "usage : $0 <hostname> <group> <user> <password>"
    exit 1
}

# Keycloak automated authentication -> failing, see below
# NONCE=$(openssl rand -base64 16 | tr -d '=')
# echo "Keycloak authentication (direct grant)"
# KC_TOKENS=$(curl --silent -X POST "https://${KC_HOSTNAME}/realms/${KEYCLOAK_REALM_NAME}/protocol/openid-connect/token" \
#   --insecure \
#   -d "username=${GUACAMOLE_ADMIN_USER}" \
#   -d "password=${GUACAMOLE_ADMIN_PASSWORD}" \
#   -d 'grant_type=password' \
#   -d 'response_type=id_token' \
#   -d 'scope=openid+email+profile' \
#   -d "redirect_uri=https%3A%2F%2F${GUAC_HOSTNAME}%2Fguacamole" \
#   -d "nonce=${NONCE}" \
#   -d "client_id=guacamole")
# testRC

# #extracting Keycloak ID Token 
# echo ${KC_TOKENS} |jq
# ACCESS_TOKEN=$(echo ${KC_TOKENS} |jq -r '.access_token')
# ID_TOKEN=$(echo ${KC_TOKENS} |jq -r '.id_token')
# #echo "access : ${ACCESS_TOKEN}"
# echo "ID token : "
# echo ${ID_TOKEN} | jq -R 'split(".") | .[0],.[1] | @base64d | fromjson'


# # Fails Here : id token doesn't have nonce claim embedded 
# echo "authentication propagation to giuacamole with id_token"
# curl -X POST "https://${GUAC_HOSTNAME}/guacamole/api/tokens" \
#      --insecure --silent\
#      --header "Content-Type: application/x-www-form-urlencoded" \
#      -d "id_token=${ID_TOKEN}" 

# direct authentication [ with guacadmin local account ] is not working : ()

echo " With Keycloak/OpenID enabled, you need to :"
echo "  1. authenticate with admin account @ ${GUACAMOLE_URL}"
echo "  2. open the developer console of your browser (F12)"
echo "  3. Inspect any Fetch/XHR operation : you'll find the token in the request headers named guacamole-token"
read -s -p "  paste it here : " GUACAMOLE_TOKEN

# Create RDP connection
# https://github.com/ridvanaltun/guacamole-rest-api-documentation/blob/master/docs/CONNECTIONS.md#create-rdp-connection
curl -X POST https://${GUAC_HOSTNAME}/guacamole/api/session/data/{{data_source}}/connections \
     --header "Guacamole-Token: ${GUACAMOLE_TOKEN}" \
     --header "Content-Type: application/json" \
     --silent --insecure \
     --data-binary @- << EOF
{
  "parentIdentifier": "ROOT",
  "name": "test",
  "protocol": "rdp",
  "parameters": {
    "port": "",
    "read-only": "",
    "swap-red-blue": "",
    "cursor": "",
    "color-depth": "",
    "clipboard-encoding": "",
    "disable-copy": "",
    "disable-paste": "",
    "dest-port": "",
    "recording-exclude-output": "",
    "recording-exclude-mouse": "",
    "recording-include-keys": "",
    "create-recording-path": "",
    "enable-sftp": "",
    "sftp-port": "",
    "sftp-server-alive-interval": "",
    "enable-audio": "",
    "security": "",
    "disable-auth": "",
    "ignore-cert": "",
    "gateway-port": "",
    "server-layout": "",
    "timezone": "",
    "console": "",
    "width": "",
    "height": "",
    "dpi": "",
    "resize-method": "",
    "console-audio": "",
    "disable-audio": "",
    "enable-audio-input": "",
    "enable-printing": "",
    "enable-drive": "",
    "create-drive-path": "",
    "enable-wallpaper": "",
    "enable-theming": "",
    "enable-font-smoothing": "",
    "enable-full-window-drag": "",
    "enable-desktop-composition": "",
    "enable-menu-animations": "",
    "disable-bitmap-caching": "",
    "disable-offscreen-caching": "",
    "disable-glyph-caching": "",
    "preconnection-id": "",
    "hostname": "",
    "username": "",
    "password": "",
    "domain": "",
    "gateway-hostname": "",
    "gateway-username": "",
    "gateway-password": "",
    "gateway-domain": "",
    "initial-program": "",
    "client-name": "",
    "printer-name": "",
    "drive-name": "",
    "drive-path": "",
    "static-channels": "",
    "remote-app": "",
    "remote-app-dir": "",
    "remote-app-args": "",
    "preconnection-blob": "",
    "load-balance-info": "",
    "recording-path": "",
    "recording-name": "",
    "sftp-hostname": "",
    "sftp-host-key": "",
    "sftp-username": "",
    "sftp-password": "",
    "sftp-private-key": "",
    "sftp-passphrase": "",
    "sftp-root-directory": "",
    "sftp-directory": ""
  },
  "attributes": {
    "max-connections": "",
    "max-connections-per-user": "",
    "weight": "",
    "failover-only": "",
    "guacd-port": "",
    "guacd-encryption": "",
    "guacd-hostname": ""
  }
}
EOF

# Create an SSH connexion
# https://github.com/ridvanaltun/guacamole-rest-api-documentation/blob/master/docs/CONNECTIONS.md#create-ssh-connection

# Create a user group
# https://github.com/ridvanaltun/guacamole-rest-api-documentation/blob/master/docs/USER-GROUPS.md#create-user-group
