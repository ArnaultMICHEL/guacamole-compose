resource "guacamole_connection_ssh" "prj1_vm1_ssh" {
  name = "Test SSH Connection"
  parent_identifier = guacamole_connection_group.group_prj_1.identifier
  parameters {
    hostname = "testing.example.com"
    username = "user"
    private_key = <<-EOT
    -----BEGIN RSA PRIVATE KEY-----
    Your private key content
    -----END RSA PRIVATE KEY-----
    EOT
    port = 22
    disable_copy = false
    color_scheme = "green-black"
    font_size = 48
    timezone = "America/Chicago"
    terminal_type = "xterm-25color"
    sftp_enable = true
    sftp_root_directory = "/home/user"
  }
}

# https://registry.terraform.io/providers/techBeck03/guacamole/latest/docs/resources/connection_rdp
resource "guacamole_connection_rdp" "prj1_vm1_rdp" {
  name = "Test RDP Connection"
  parent_identifier = guacamole_connection_group.group_prj_1.identifier
  parameters {
    #Network
    hostname = "testvm.fqdn.or.ip"
    port = 3389
    #Authentication
    username = "user"
    password = "PASSWD"
    security_mode = "any"
    ignore_cert = true
    #Display
    color_depth = 16
    resize_method = "display-update"
    readonly = false
    #Clipboard
    disable_copy = false
    disable_paste = false
    #Remote Desktop Gateway
    timezone = "Europe/Paris"
    #Device Redirection
    console_audio = true
    disable_audio = true
    enable_audio_input = false
    enable_printing = false
    enable_drive = false
    disable_file_download = false
    disable_file_upload = false
    #SFTP - file dwl/upload
    sftp_enable = true
    sftp_root_directory = "/home/user"
    sftp_hostname = "testvm.fqdn.or.ip"
    sftp_port = 22
    sftp_username = "user"
    sftp_password = "PASSWD"
    sftp_disable_file_download = true
    sftp_disable_file_upload = true
    sftp_private_key = <<-EOT
    -----BEGIN RSA PRIVATE KEY-----
    Your private key content
    -----END RSA PRIVATE KEY-----
    EOT
  }
}