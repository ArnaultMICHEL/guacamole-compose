# doc : https://registry.terraform.io/providers/techBeck03/guacamole/latest/docs/resources/user_group

resource "guacamole_user_group" "group_guacamole_user" {
  identifier = "Guacamole-Users"
  connections = [ 
    guacamole_connection_ssh.prj1_vm1_ssh.identifier,
    guacamole_connection_rdp.prj1_vm1_rdp.identifier
  ]
  connection_groups = [
    guacamole_connection_group.group_prj_1.identifier
  ]
  attributes {
    disabled = false
  }
}

resource "guacamole_user_group" "group_guacamole_admin" {
  identifier = "Guacamole-Admins"
  system_permissions = ["ADMINISTER","CREATE_CONNECTION","CREATE_CONNECTION_GROUP","CREATE_SHARING_PROFILE","CREATE_USER","CREATE_USER_GROUP"]
  attributes {
    disabled = false
  }
}
