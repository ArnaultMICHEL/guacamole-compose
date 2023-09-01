
#TODO
resource "keycloak_realm" "guacamole" {

  #General
  realm   = var.keycloak_realm
  enabled = true
  display_name = "Guacamole dedicated realm"
  display_name_html = "\u003ch2\u003eGuacamole\u003c/h2\u003e\u003cp\u003edeleguated auth\u003c/p\u003e"
  user_managed_access = false

  #Login Settings
  registration_allowed     = false
  registration_email_as_username = false
  edit_username_allowed    = false
  reset_password_allowed   = false
  remember_me              = false
  verify_email             = false
  login_with_email_allowed = true
  duplicate_emails_allowed = false
  ssl_required             = "external"

  #Themes
  login_theme   = "keycloak"
  email_theme   = "keycloak"
  account_theme = "keycloak.v2"
  admin_theme   = "keycloak.v2"

  #Keys
            
  #Emails
  #smtp_server {
  #  host = "mailer.fqdn"
  #  from = "bal@mycompany.com"
  #  port = "25"
  #  from_display_name = "Keycloak for Guacamole"
  #  ssl = false
  #  starttls = true
  #  auth {
  #    username = "XXX"
  #    password = "YYY"
  #  }
  #}

  # Auth flows Settings
  #browser_flow = "X509Browser"
  browser_flow = "browser"
  docker_authentication_flow = "docker auth"
  client_authentication_flow = "clients"
  direct_grant_flow = "direct grant"
  reset_credentials_flow = "reset credentials"
  password_policy = "upperCase(1) and length(12) and forceExpiredPasswordChange(365) and notUsername"

  default_default_client_scopes  = []
  default_optional_client_scopes = []

  #Tokens
  default_signature_algorithm = ""
  revoke_refresh_token = false

    #Login timeout
  access_code_lifespan = "1m0s"
  access_code_lifespan_login = "30m0s"
  access_code_lifespan_user_action = "5m0s"

  access_token_lifespan = "5m0s"
  access_token_lifespan_for_implicit_flow  = "15m0s"
  
  action_token_generated_by_admin_lifespan = "12h0m0s"
  action_token_generated_by_user_lifespan  = "5m0s"

  sso_session_idle_timeout = "30m0s"
  sso_session_idle_timeout_remember_me = "0s"
  sso_session_max_lifespan = "10h0m0s"
  sso_session_max_lifespan_remember_me = "0s"

  offline_session_idle_timeout = "720h0m0s"
  offline_session_max_lifespan = "1440h0m0s"
  offline_session_max_lifespan_enabled = false

  internationalization {
    supported_locales = [
      "en",
      "de",
      "es",
      "fr",
      "it"
    ]
    default_locale    = "fr"
  }

  otp_policy {
    algorithm = "HmacSHA512"
    digits = 6
    initial_counter = 0
    look_ahead_window = 1
    period = 30
    type   = "totp"
  }

  security_defenses {
    headers {
      x_frame_options                     = "DENY"
      content_security_policy             = "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options              = "nosniff"
      x_robots_tag                        = "none"
      x_xss_protection                    = "1; mode=block"
      strict_transport_security           = "max-age=31536000; includeSubDomains"
    }
    brute_force_detection {
      permanent_lockout                 = false
      max_login_failures                = 30
      wait_increment_seconds            = 60
      quick_login_check_milli_seconds   = 1000
      minimum_quick_login_wait_seconds  = 60
      max_failure_wait_seconds          = 900
      failure_reset_time_seconds        = 43200
    }
  }
  web_authn_policy {
    acceptable_aaguids = []
    attestation_conveyance_preference = "not specified"
    authenticator_attachment = "not specified"
    avoid_same_authenticator_register = false
    create_timeout = 0
    relying_party_entity_name = "keycloak"
    relying_party_id = "keycloak.example.com"
    require_resident_key = "not specified"
    signature_algorithms =  ["ES256", "ES512", "RS256", "RS512"]
    user_verification_requirement = "not specified"
  }

}


####################################
##  client for Guacamole webapps  ##
####################################

#https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client
resource "keycloak_openid_client" "guacamole_openid_client" {
  realm_id               = var.keycloak_realm
  client_id              = "guacamole"

  name                   = "guacamole"
  enabled                = true
  description            = "Guacamole webapp"

  access_type            = "PUBLIC"

  standard_flow_enabled        = false
  implicit_flow_enabled        = true
  direct_access_grants_enabled = true
  service_accounts_enabled     = false
  frontchannel_logout_enabled  = false
  #frontchannel_logout_url     =


  valid_redirect_uris = [
    var.guacamole_openid_callback
  ]
  #valid_post_logout_redirect_uris =
  web_origins = [
    var.guacamole_web_origins
  ]
  root_url = var.guacamole_root_url

  login_theme = "keycloak"
  
  depends_on = [ keycloak_realm.guacamole ]
}

# create two sample client role
resource "keycloak_role" "guacamole_admin_client_role" {
  realm_id    = var.keycloak_realm
  client_id   = keycloak_openid_client.guacamole_openid_client.id
  name        = "Guacamole-Admins"
  description = "A Role that is mapped on Guacamole group"
}
resource "keycloak_role" "guacamole_users_client_role" {
  realm_id    = var.keycloak_realm
  client_id   = keycloak_openid_client.guacamole_openid_client.id
  name        = "Guacamole-Users"
  description = "A Role that is mapped on Guacamole group"
}

#########################################
##  client scope for Guacamole groups  ##
#########################################

resource "keycloak_openid_client_scope" "openid_client_scope" {
  realm_id               = var.keycloak_realm
  name                   = "guacamole-groups"
  description            = "When requested, this scope will map client role to a claim named groups, which must correspond to a guacamole's group memberships"
  include_in_token_scope = true
  gui_order              = 1
  depends_on = [ keycloak_realm.guacamole ]
}

resource "keycloak_openid_user_client_role_protocol_mapper" "user_client_role_mapper" {
  realm_id        = var.keycloak_realm
  client_scope_id = keycloak_openid_client_scope.openid_client_scope.id
  name            = "user-client-role-mapper"
  client_id_for_role_mappings  = keycloak_openid_client.guacamole_openid_client.name
  claim_name      = "groups"
  multivalued     = true
  add_to_id_token = true
  add_to_access_token = false
  add_to_userinfo = false
}

resource "keycloak_openid_client_default_scopes" "guacamole_client_default_scopes" {
  realm_id  = var.keycloak_realm
  client_id = keycloak_openid_client.guacamole_openid_client.id

  default_scopes = [
    "profile",
    "email",
    "profile",
    keycloak_openid_client_scope.openid_client_scope.name,
  ]
}

##################################
##  Authentication Flow for MFA ##
##################################

#keycloak_authentication_flow.browser-copy-flow.id
resource "keycloak_authentication_flow" "browser_x509_flow" {
  alias       = "X509Browser"
  realm_id    = var.keycloak_realm
  description = "browser based authentication, With IGCv3 X.509"
  provider_id = "basic-flow"
  depends_on = [ keycloak_realm.guacamole ]
}

resource "keycloak_authentication_execution" "browser_copy_cookie" {
  realm_id          = var.keycloak_realm
  parent_flow_alias = keycloak_authentication_flow.browser_x509_flow.alias
  authenticator     = "auth-cookie"
  requirement       = "ALTERNATIVE"
}

resource "keycloak_authentication_execution" "browser_copy_kerberos" {
  realm_id          = var.keycloak_realm
  parent_flow_alias = keycloak_authentication_flow.browser_x509_flow.alias
  authenticator     = "auth-spnego"
  requirement       = "DISABLED"
  depends_on        = [ keycloak_authentication_execution.browser_copy_cookie ]
}

resource "keycloak_authentication_execution" "browser_copy_default_idp" {
  realm_id          = var.keycloak_realm
  parent_flow_alias = keycloak_authentication_flow.browser_x509_flow.alias
  authenticator     = "identity-provider-redirector"
  requirement       = "DISABLED"
  depends_on        = [ keycloak_authentication_execution.browser_copy_kerberos ]
}

#resource "keycloak_authentication_execution_config" "config" {
#  realm_id     = var.keycloak_realm
#  execution_id = keycloak_authentication_execution.browser_copy_default_idp.id
#  alias        = "idp-FBI-config"
#  config       = {
#    defaultProvider = "idp-FBI"
#  }
#}

resource "keycloak_authentication_execution" "browser_x509" {
  realm_id          = var.keycloak_realm
  parent_flow_alias = keycloak_authentication_flow.browser_x509_flow.alias
  authenticator     = "auth-x509-client-username-form"
  requirement       = "REQUIRED"
  depends_on        = [ keycloak_authentication_execution.browser_copy_default_idp ]
}

resource "keycloak_authentication_execution_config" "mfa_config" {
  realm_id     = var.keycloak_realm
  execution_id = keycloak_authentication_execution.browser_x509.id
  alias        = "MFA-IGCv3-Token"
  config = {
		"x509-cert-auth.canonical-dn-enabled"     = "false"
		"x509-cert-auth.extendedkeyusage"         = "1.3.6.1.5.5.7.3.2"
		"x509-cert-auth.serialnumber-hex-enabled" = "false"
		"x509-cert-auth.regular-expression"       = "(.*?)(?:$)"
		"x509-cert-auth.mapper-selection"         = "Username or Email"
		"x509-cert-auth.crl-relative-path"        = "crl.pem"
		"x509-cert-auth.crldp-checking-enabled"   = "true"
		"x509-cert-auth.mapping-source-selection" = "Subject's Alternative Name E-mail",
		"x509-cert-auth.timestamp-validation-enabled" = "true"
  }
}

resource "keycloak_authentication_subflow" "browser_conditional_otp" {
  realm_id          = var.keycloak_realm
  alias             = "Conditional_OTP"
  parent_flow_alias = keycloak_authentication_flow.browser_x509_flow.alias
  authenticator     = "auth-x509-client-username-form"
  requirement       = "CONDITIONAL"
  depends_on        = [ keycloak_authentication_execution.browser_x509 ]
}

resource "keycloak_authentication_execution" "otp_user_configured" {
  realm_id          = var.keycloak_realm
  parent_flow_alias = keycloak_authentication_subflow.browser_conditional_otp.alias
  authenticator     = "conditional-user-configured"
  requirement       = "REQUIRED"
}

resource "keycloak_authentication_execution" "otp_conditional_form" {
  realm_id          = var.keycloak_realm
  parent_flow_alias = keycloak_authentication_subflow.browser_conditional_otp.alias
  authenticator     = "auth-otp-form"
  requirement       = "REQUIRED"
  depends_on        = [ keycloak_authentication_execution.otp_user_configured ]
}

