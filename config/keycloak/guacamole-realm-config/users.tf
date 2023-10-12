# Add users and theirs roles here

# This unprivileged user is given as an example, you can remove or replace it
resource "keycloak_user" "guacamole_sample_user" {
  realm_id   = keycloak_realm.guacamole.id
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
  realm_id = keycloak_realm.guacamole.id
  user_id  = keycloak_user.guacamole_sample_user.id

  role_ids = [
    keycloak_role.guacamole_users_client_role.id
  ]
}

# Keep this account for first start
resource "keycloak_user" "guacamole_admin_user" {
  realm_id   = keycloak_realm.guacamole.id
  username   = var.guacamole_admin_login
  enabled    = true
  email      = "guacadmin@guacadmin.local"
  first_name = "Guacamole"
  last_name  = "First Admin"

  initial_password {
    value     = var.guacamole_admin_password
    temporary = true
  }
}

resource "keycloak_user_roles" "guacamole_admin_user_roles" {
  realm_id =keycloak_realm.guacamole.id
  user_id  = keycloak_user.guacamole_admin_user.id

  role_ids = [
    keycloak_role.guacamole_admin_client_role.id
  ]
}
