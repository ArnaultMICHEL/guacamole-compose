
#!/bin/bash

source $(dirname $0)/../.secrets.env
source $(dirname $0)/../.shared_cli_functions.sh

# check CLI parameters
[[ $1 == "" ]] && {
    echo "usage : $0 <project-name>"
    exit 1
}

[[ -z ${GUACAMOLE_TOKEN} ]] && {
  echo " With Keycloak/OpenID enabled, you need to :"
  echo "  1. authenticate with an admin account @ ${GUACAMOLE_URL}"
  echo "  2. open the developer console of your browser : F12"
  echo "  3. Inspect any Fetch/XHR operation : you'll find the token in the request headers named Guacamole-Token, copy it"
  read -s -p "  paste it here : " GUACAMOLE_TOKEN
}

# Create a new connection group (~project)
# https://github.com/ridvanaltun/guacamole-rest-api-documentation/blob/master/docs/CONNECTIONS.md#create-rdp-connection
curl -X POST https://${GUAC_HOSTNAME}/guacamole/api/session/data/postgresql/connectionGroups \
     --header "Guacamole-Token: ${GUACAMOLE_TOKEN}" \
     --header "Content-Type: application/json; charset=utf-8" \
     --silent --insecure \
     --data-binary @- << EOF{
    "parentIdentifier":"ROOT",
    "name":"$1",
    "type":"ORGANIZATIONAL",
    "attributes":{
        "max-connections":"",
        "max-connections-per-user":"",
        "enable-session-affinity":""
    }
}
EOF