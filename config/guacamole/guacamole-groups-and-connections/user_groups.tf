resource "guacamole_user_group" "group_prj1_vm1" {
  identifier = "Project1_VM1"
  # system_permissions = ["ADMINISTER", "CREATE_USER"]
  # group_membership = []
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