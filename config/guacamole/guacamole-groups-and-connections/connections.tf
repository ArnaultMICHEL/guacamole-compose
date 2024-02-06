# doc : https://registry.terraform.io/providers/techBeck03/guacamole/latest/docs/resources/connection_ssh
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
    # Text Session Recording, use scriptreplay file.timing file
    typescript_path = "${HISTORY_PATH}/${HISTORY_UUID}"
    typescript_name = "${GUAC_DATE}_${GUAC_TIME}_${GUAC_USERNAME}_${GUAC_CLIENT_ADDRESS}_ssh"
    typescript_auto_create_path = true
  }
}

# doc : https://registry.terraform.io/providers/techBeck03/guacamole/latest/docs/resources/connection_rdp
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
    #session recording
    recording_path = "${HISTORY_PATH}/${HISTORY_UUID}"
    recording_name = "${GUAC_DATE}_${GUAC_TIME}_${GUAC_USERNAME}_${GUAC_CLIENT_ADDRESS}_rdp"
    recording_exclude_output = false    # exclude graphics/streams
    recording_exclude_mouse  = false    # exclude mouse
    recording_include_keys   = false    # include key events
    recording_auto_create_path = true
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