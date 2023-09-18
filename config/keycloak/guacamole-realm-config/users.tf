# add your users here

# resource "keycloak_user" "user_with_initial_password" {
#   realm_id   = var.keycloak_realm
#   username   = "alice"
#   enabled    = true

#   email      = "alice@domain.com"
#   first_name = "Alice"
#   last_name  = "Aliceberg"

#   attributes = {
#     foo = "bar"
#     multivalue = "value1##value2"
#   }

#   initial_password {
#     value     = "some password"
#     temporary = true
#   }
# }