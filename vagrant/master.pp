notify { 'Installing Master': }

class { '::keycloak':
  operating_mode          => 'domain',
  role                    => 'master',
  management_bind_address => '192.168.168.253',
  enable_jdbc_ping        => true,
  wildfly_user            => $keycloak_wildfly_user,
  wildfly_user_password   => $keycloak_wildfly_user_password,
  manage_install          => true,
  manage_datasource       => false,
  version                 => $keycloak_version,
  datasource_driver       => 'postgresql',
  datasource_host         => $keycloak_datasource_host,
  datasource_port         => 5432,
  datasource_dbname       => $keycloak_datasource_dbname,
  datasource_username     => $keycloak_datasource_username,
  datasource_password     => $keycloak_datasource_password,
  admin_user              => $keycloak_admin_user,
  admin_user_password     => $keycloak_admin_user_password,
  service_bind_address    => '0.0.0.0',
  proxy_https             => false,
  syslog                  => true,
}

keycloak_realm { 'TEST.NET':
  ensure                       => 'present',
  display_name                 => 'TEST.NET',
  display_name_html            => '<strong>TEST.NET</strong>',
  login_with_email_allowed     => false,
  remember_me                  => false,
  events_enabled               => true,
  admin_events_enabled         => true,
  admin_events_details_enabled => true,
}

keycloak_client { 'example.com':
  ensure                   => 'present',
  realm                    => 'TEST.NET',
  standard_flow_enabled    => true,
  protocol                 => 'saml',
  full_scope_allowed       => true,
  service_accounts_enabled => false,
  base_url                 => 'https://example.com/',
  redirect_uris            => [
    'https://example.com/',
    'https://example.com/*',
  ],
  require                  => Keycloak_realm['TEST.NET'],
}

