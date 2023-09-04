# Guacamole API reference

<https://github.com/ridvanaltun/guacamole-rest-api-documentation/>

Unfortunately, I was not able to pass the authentication :

- Guacamole OpenID authenticator is checking a nonce claim in id_token
- Keycloack is not setting this claim in the id_token with direct grant (CLI) login

# Keycloak CLI scripts

## `keycloak-add-user.sh`

This script create a local account with a temporary password, and propose to link client roles (=guacamole user group) to this account

Input parameters : 

## `keycloak-add-gucamole-role.sh`

This script create new guacamole client roles.

Please note that they **must be exactly equals to a guacamole user's group** in https://${GUAC_HOSTNAME}/guacamole/#/settings/userGroups

## Documentation

- https://www.keycloak.org/docs/latest/server_admin/index.html#admin-cli