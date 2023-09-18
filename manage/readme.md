# Guacamole API reference

<https://github.com/ridvanaltun/guacamole-rest-api-documentation/>

Unfortunately, I was not able to pass the authentication :

- Guacamole OpenID authenticator is checking a nonce claim in id_token
- Keycloack is not setting this claim in the id_token with direct grant (CLI) login

 - [ ] TODO : ask for a token after a manual authentication, then call rest API's with curl 

# Keycloak CLI scripts

## `keycloak-add-user.sh`

This script create a local account with a temporary password, and propose to link client roles (=guacamole user group) to this account

Input parameters : 

## `keycloak-add-gucamole-role.sh`

This script create new guacamole client roles.

Please note that they **must be exactly equals to a guacamole user's group** in https://${GUAC_HOSTNAME}/guacamole/#/settings/userGroups

## Documentation

- https://www.keycloak.org/docs/latest/server_admin/index.html#admin-cli


# Guacamole CLI scripts

It was not working, I was not able to manage CLI authentication as guacamole complain about the nonce claim :

```bash
$ curl -X POST "https://${GUAC_HOSTNAME}/guacamole/api/tokens" \
     --insecure --silent\
     --header "Content-Type: application/x-www-form-urlencoded" \
     -d "id_token=${ID_TOKEN}" 

{
    "message":"Invalid login.",
    "translatableMessage": {
        "key":"APP.TEXT_UNTRANSLATED",
        "variables": {
            "MESSAGE":"Invalid login."
        }
    },
    "statusCode":null,
    "expected":[
        {
            "name":"id_token",
            "type":"REDIRECT",
            "redirectUrl":"https://sso.poc.eclair.cloud/realms/guacamole/protocol/openid-connect/auth?scope=openid+email+profile&response_type=id_token&client_id=guacamole&redirect_uri=https%3A%2F%2Fguacamole.poc.eclair.cloud%2Fguacamole&nonce=mlggr781ndofggpolfo010gma8",
            "translatableMessage": {
                "key":"LOGIN.INFO_IDP_REDIRECT_PENDING",
                "variables":null
            }
        }
    ],
    "type":"INVALID_CREDENTIALS"
}
```

guacd logs show : 

```text
09:12:20.290 [https-openssl-apr-8443-exec-4] INFO  o.a.g.a.o.t.TokenValidationService - Rejected OpenID token without nonce.
```