# Doc : https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs

# Pre requisites : source .env to set
#   export KEYCLOAK_CLIENT_SECRET=UUID \
#   export KEYCLOAK_CLIENT_TIMEOUT=5 \

terraform {
  required_providers {
    keycloak = {
      source = "techBeck03/guacamole"
      version = ">= 1.4.1"
    }
  }
}

# Configure the Guacamole Provider
provider "guacamole" {
 # url         = "https://guacamole.example.com"
  #token       = "8675309"
  data_source = "postgresql"
  disable_tls_verification = true
}