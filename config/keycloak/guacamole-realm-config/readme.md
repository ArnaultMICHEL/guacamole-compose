# Keycloack Terraform module

[Terraform module for Keycloak](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs) configure a realm of an exiting Keycloack instance

## Available Features

This module manage the following elements on realm cloud-public :
- global realm settings : Tokens TTL, security defenses on HTTP, ...
- Authentication flow for X509Browser with smartcard MFA Support (X509 mandatory, OTP optionnal)
- Add a client scope for automatic mapping of Keycloak client role to guacamole groups ( 'groups' claim in ID token)

## Required environment variables

```bash
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
```