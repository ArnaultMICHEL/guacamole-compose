# add your users here

resource "keycloak_user" "guacamole_sample_user" {
  realm_id   = var.keycloak_realm
  username   = "guacuser"
  enabled    = true

  email      = "alice@domain.com"
  first_name = "Alice"
  last_name  = "Aliceberg"

  initial_password {
    value     = "Alice123456789"
    temporary = true
  }
}

resource "keycloak_user_roles" "guacamole_sample_user_roles" {
  realm_id = var.keycloak_realm
  user_id  = keycloak_user.guacamole_sample_user.id

  role_ids = [
    keycloak_role.guacamole_users_client_role.id
  ]
}

resource "keycloak_user" "guacamole_admin_user" {
  realm_id   = var.keycloak_realm
  username   = "guacadmin@guacadmin"
  enabled    = true

  email      = "guacadmin@guacadmin"
  first_name = "Guacamole"
  last_name  = "First Admin"

  initial_password {
    value     = "guacAdmin@guacAdmin"
    temporary = true
  }
}

resource "keycloak_user_roles" "guacamole_admin_user_roles" {
  realm_id = var.keycloak_realm
  user_id  = keycloak_user.guacamole_admin_user.id

  role_ids = [
    keycloak_role.guacamole_admin_client_role.id
  ]
}
