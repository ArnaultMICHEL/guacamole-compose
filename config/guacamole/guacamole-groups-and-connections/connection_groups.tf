#doc : https://registry.terraform.io/providers/techBeck03/guacamole/latest/docs/resources/connection_group

resource "guacamole_connection_group" "group_prj_1" {
  parent_identifier = "ROOT"
  name = "Project1"
  type = "organizational"
  attributes {
    max_connections_per_user = 4
  }
}