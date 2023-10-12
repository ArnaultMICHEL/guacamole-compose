
variable "keycloak_realm" {
  description = "keycloak realm name"
  type = string
}
variable "root_ca_cert" {
  description = "CA that signs keycloak TLS server certificate"
  type = string
}

variable "guacamole_openid_callback" {
  description = "Guacamole OpenID callback URL"
  type = string
}

variable "guacamole_root_url" {
  description = "Guacamole OpenID callback URL"
  type = string
}

variable "guacamole_web_origins" {
  description = "Guacamole web origins for CORS"
  type = string
}

variable "guacamole_admin_login" {
  description = "Guacamole admin login, from GUACAMOLE_ADMIN_USER env var in .env"
  type = string
}

variable "guacamole_admin_password" {
  description = "Guacamole admin password, from GUACAMOLE_ADMIN_TEMP_PASSWORD env var in .env"
  type = string
}
