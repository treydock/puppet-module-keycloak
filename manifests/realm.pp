#
define keycloak::realm (
  Optional[String] $display_name = undef,
  Optional[String] $display_name_html = undef,
  Boolean $remember_me = false,
  Boolean $login_with_email_allowed = true,
  String $login_theme = 'keycloak',
  String $account_theme = 'keycloak',
  String $admin_theme = 'keycloak',
  String $email_theme = 'keycloak',
) {

  warning('Keycloak::Realm is deprecated, use keycloak_realm type directly')

  include ::keycloak
  realize Keycloak_conn_validator['keycloak']

  keycloak_realm { $name:
    display_name             => $display_name,
    display_name_html        => $display_name_html,
    remember_me              => $remember_me,
    login_with_email_allowed => $login_with_email_allowed,
    login_theme              => $login_theme,
    account_theme            => $account_theme,
    admin_theme              => $admin_theme,
    email_theme              => $email_theme,
  }

}
