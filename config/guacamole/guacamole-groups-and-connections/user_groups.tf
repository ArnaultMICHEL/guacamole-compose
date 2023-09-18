resource "guacamole_user_group" "group" {
  identifier = "testGuacamoleUserGroup"
  #system_permissions = ["ADMINISTER", "CREATE_USER"]
  #group_membership = ["Parent Group"]
  connections = [
    "12345"
  ]
  connection_groups = [
    "ConnectionGroup1"
  ]
  attributes {
    disabled = false
  }
}