
# create two sample client role
resource "keycloak_role" "guacamole_admin_client_role" {
  realm_id    = var.keycloak_realm
  client_id   = keycloak_openid_client.guacamole_openid_client.id
  name        = "Guacamole-Admins"
  description = "A Role that is mapped on Guacamole group"
}
resource "keycloak_role" "guacamole_users_client_role" {
  realm_id    = var.keycloak_realm
  client_id   = keycloak_openid_client.guacamole_openid_client.id
  name        = "Guacamole-Users"
  description = "A Role that is mapped on Guacamole group"
}

# add your own client roles here