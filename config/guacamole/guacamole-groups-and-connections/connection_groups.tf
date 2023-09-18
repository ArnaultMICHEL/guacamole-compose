resource "guacamole_connection_group" "group" {
  parent_identifier = "ROOT"
  name = "ConnectionGroup1"
  type = "organizational"
  attributes {
    max_connections_per_user = 4
  }
}