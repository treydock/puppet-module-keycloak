notify { 'Installing Slave': }

class { '::keycloak':
  operating_mode          => 'domain',
  role                    => 'slave',
  enable_jdbc_ping        => true,
  management_bind_address => '192.168.168.252',
  wildfly_user            => $keycloak_wildfly_user,
  wildfly_user_password   => $keycloak_wildfly_user_password,
  master_address          => '192.168.168.253',
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

