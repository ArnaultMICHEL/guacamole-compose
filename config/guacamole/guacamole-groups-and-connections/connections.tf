resource "guacamole_connection_ssh" "ssh" {
  name = "Test SSH Connection"
  parent_identifier = "ConnectionGroup1"
  attributes {
    guacd_hostname = "guac.test.com"
    guacd_encryption = "ssl"
  }
  parameters {
    hostname = "testing.example.com"
    username = "root"
    private_key = <<-EOT
    -----BEGIN RSA PRIVATE KEY-----
    Your private key content
    -----END RSA PRIVATE KEY-----
    EOT
    port = 22
    disable_copy = true
    color_scheme = "green-black"
    font_size = 48
    timezone = "America/Chicago"
    terminal_type = "xterm-256color"
    sftp_enable = true
    sftp_root_directory = "/root"
  }
}