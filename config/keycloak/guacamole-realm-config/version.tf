# Doc : https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs

# Pre requisites : source .env to set
#   export KEYCLOAK_CLIENT_SECRET=UUID \
#   export KEYCLOAK_CLIENT_TIMEOUT=5 \

terraform {
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = ">= 4.3.1"
    }
  }
}

# Configure the Keycloak Provider
provider "keycloak" {
  root_ca_certificate = var.root_ca_cert
  tls_insecure_skip_verify = true
}
