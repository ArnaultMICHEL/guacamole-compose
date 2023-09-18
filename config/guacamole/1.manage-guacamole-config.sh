#!/bin/bash

source $(dirname $0)/../../.secrets.env

source $(dirname $0)/../../.shared_cli_functions.sh

echo " With Keycloak/OpenID enabled, you need to :"
echo "  1. authenticate with admin account @ ${GUACAMOLE_URL}"
echo "  2. open the developer console of your browser (F12)"
echo "  3. Inspect any Fetch/XHR operation : you'll find the token in the request headers named guacamole-token"
read -s -p "  paste it here : " GUACAMOLE_TOKEN

#TODO : check token with a sample curl call on APIs

cd guacamole-groups-and-connections

terraform init
terraform apply