# @summary Manage Keycloak
#
# @example
#   include ::keycloak
#
# @param manage_install
#   Install Keycloak from upstream Keycloak tarball.
#   Set to false to manage installation of Keycloak outside
#   this module and set $install_dir to match.
#   Defaults to true.
# @param version
#   Version of Keycloak to install and manage.
# @param package_url
#   URL of the Keycloak download.
#   Default is based on version.
# @param install_dir
#   The directory of where to install Keycloak.
#   Default is `/opt/keycloak-${version}`.
# @param service_name
#   Keycloak service name.
#   Default is `keycloak`.
# @param service_ensure
#   Keycloak service ensure property.
#   Default is `running`.
# @param service_enable
#   Keycloak service enable property.
#   Default is `true`.
# @param service_hasstatus
#   Keycloak service hasstatus parameter.
#   Default is `true`.
# @param service_hasrestart
#   Keycloak service hasrestart parameter.
#   Default is `true`.
# @param service_bind_address
#   Bind address for Keycloak service.
#   Default is '0.0.0.0'.
# @param management_bind_address
#   Bind address for Keycloak management.
#   Default is '0.0.0.0'.
# @param java_opts
#   Sets additional options to Java virtual machine environment variable.
# @param java_opts_append
#   Determine if $JAVA_OPTS should be appended to when setting `java_opts` parameter
# @param service_extra_opts
#   Additional options added to the end of the service command-line.
# @param manage_user
#   Defines if the module should manage the Linux user for Keycloak installation
# @param user
#   Keycloak user name.
#   Default is `keycloak`.
# @param user_shell
#   Keycloak user shell.
# @param group
#   Keycloak user group name.
#   Default is `keycloak`.
# @param user_uid
#   Keycloak user UID.
#   Default is `undef`.
# @param group_gid
#   Keycloak user group GID.
#   Default is `undef`.
# @param system_user
#   If keycloak user should be a system user with lower uid and gid.
#   Default is `true`
# @param admin_user
#   Keycloak administrative username.
#   Default is `admin`.
# @param admin_user_password
#   Keycloak administrative user password.
#   Default is `changeme`.
# @param wildfly_user
#   Wildfly user. Required for domain mode.
# @param wildfly_user_password
#   Wildfly user password. Required for domain mode.
# @param manage_datasource
#   Boolean that determines if configured datasource will be managed.
#   Default is `true`.
# @param datasource_driver
#   Datasource driver to use for Keycloak.
#   Valid values are `h2`, `mysql`, 'oracle' and 'postgresql'
#   Default is `h2`.
# @param datasource_host
#   Datasource host.
#   Only used when datasource_driver is `mysql`, 'oracle' or 'postgresql'
#   Default is `localhost` for MySQL.
# @param datasource_port
#   Datasource port.
#   Only used when datasource_driver is `mysql`, 'oracle' or 'postgresql'
#   Default is `3306` for MySQL.
# @param datasource_url
#   Datasource url.
#   Default datasource URLs are defined in init class.
# @param datasource_dbname
#   Datasource database name.
#   Default is `keycloak`.
# @param datasource_username
#   Datasource user name.
#   Default is `sa`.
# @param datasource_password
#   Datasource user password.
#   Default is `sa`.
# @param datasource_package
#   Package to add specified datasource support
# @param datasource_jar_source
#   Source for datasource JDBC driver - could be puppet link or local file on the node.
#   Default is dependent on value for `datasource_driver`.
#   This parameter is required if `datasource_driver` is `oracle`.
# @param datasource_jar_filename
#   Specify the filename of the destination datasource jar in the module dir of keycloak.
#   This parameter is only working at the moment if `datasource_driver` is `oracle`.
# @param datasource_module_source
#   Source for datasource module.xml. Default depends on `datasource_driver`.
# @param datasource_xa_class
#   MySQL Connector/J JDBC driver xa-datasource class name
# @param mysql_database_charset
#   MySQL database charset
# @param proxy_https
#   Boolean that sets if HTTPS proxy should be enabled.
#   Set to `true` if proxying traffic through Apache.
#   Default is `false`.
# @param truststore
#   Boolean that sets if truststore should be used.
#   Default is `false`.
# @param truststore_hosts
#   Hash that is used to define `keycloak::turststore::host` resources.
#   Default is `{}`.
# @param truststore_password
#   Truststore password.
#   Default is `keycloak`.
# @param truststore_hostname_verification_policy
#   Valid values are `WILDCARD`, `STRICT`, and `ANY`.
#   Default is `WILDCARD`.
# @param http_port
#   HTTP port used by Keycloak.
#   Default is `8080`.
# @param theme_static_max_age
#   Max cache age in seconds of static content.
#   Default is `2592000`.
# @param theme_cache_themes
#   Boolean that sets if themes should be cached.
#   Default is `true`.
# @param theme_cache_templates
#   Boolean that sets if templates should be cached.
#   Default is `true`.
# @param realms
#   Hash that is used to define keycloak_realm resources.
#   Default is `{}`.
# @param realms_merge
#   Boolean that sets if `realms` should be merged from Hiera.
# @param oidc_client_scopes
#   Hash that is used to define keycloak::client_scope::oidc resources.
#   Default is `{}`.
# @param oidc_client_scopes_merge
#   Boolean that sets if `oidc_client_scopes` should be merged from Hiera.
# @param saml_client_scopes
#   Hash that is used to define keycloak::client_scope::saml resources.
#   Default is `{}`.
# @param saml_client_scopes_merge
#   Boolean that sets if `saml_client_scopes` should be merged from Hiera.
# @param identity_providers
#   Hash that is used to define keycloak_identity_provider resources.
# @param identity_providers_merge
#   Boolean that sets if `identity_providers` should be merged from Hiera.
# @param client_protocol_mappers
#   Hash that is used to define keycloak_client_protocol_mapper resources.
# @param client_scopes
#   Hash that is used to define keycloak_client_scope resources.
# @param client_scopes_merge
#   Boolean that sets if `client_scopes` should be merged from Hiera.
# @param protocol_mappers
#   Hash that is used to define keycloak_protocol_mapper resources.
# @param protocol_mappers_merge
#   Boolean that sets if `protocol_mappers` should be merged from Hiera.
# @param clients
#   Hash that is used to define keycloak_client resources.
# @param clients_merge
#   Boolean that sets if `clients` should be merged from Hiera.
# @param flows
#   Hash taht is used to define keycloak_flow resources.
# @param flows_merge
#   Boolean that sets if `flows` should be merged from Hiera.
# @param flow_executions
#   Hash taht is used to define keycloak_flow resources.
# @param flow_executions_merge
#   Boolean that sets if `flows` should be merged from Hiera.
# @param required_actions
#   Hash that is used to define keycloak_required_action resources.
# @param required_actions_merge
#   Boolean that sets if `required_actions` should be merged from Hiera.
# @param ldap_mappers
#   Hash that is used to define keycloak_ldap_mapper resources.
# @param ldap_mappers_merge
#   Boolean that sets if `ldap_mappers` should be merged from Hiera.
# @param ldap_user_providers
#   Hash that is used to define keycloak_ldap_user_provider resources.
# @param ldap_user_providers_merge
#   Boolean that sets if `ldap_user_providers` should be merged from Hiera.
# @param role_mappings
#   Hash that is used to define keycloak_role_mapping resources.
# @param role_mappers_merge
#   Boolean that sets if `role_mappers` should be merged from Hiera.
# @param with_sssd_support
#   Boolean that determines if SSSD user provider support should be available
# @param libunix_dbus_java_source
#   Source URL of libunix-dbus-java
# @param install_libunix_dbus_java_build_dependencies
#   Boolean that determines of libunix-dbus-java build dependencies are managed by this module
# @param libunix_dbus_java_build_dependencies
#   Packages needed to build libunix-dbus-java
# @param libunix_dbus_java_libdir
#   Path to directory to install libunix-dbus-java libraries
# @param jna_package_name
#   Package name for jna
# @param manage_sssd_config
#   Boolean that determines if SSSD ifp config for Keycloak is managed
# @param sssd_ifp_user_attributes
#   user_attributes to define for SSSD ifp service
# @param restart_sssd
#   Boolean that determines if SSSD should be restarted
# @param service_environment_file
#   Path to the file with environment variables for the systemd service
# @param operating_mode
#   Keycloak operating mode deployment
# @param enable_jdbc_ping
#   Use JDBC_PING to discover the nodes and manage the replication of data
#     More info: http://jgroups.org/manual/#_jdbc_ping
#   Only applies when `operating_mode` is either `clustered` or `domain`
#   JDBC_PING uses port 7600 to ensure cluster members are discoverable by each other
#   This module does not manage firewall changes
# @param jboss_bind_public_address
#   JBoss bind public IP address
# @param jboss_bind_private_address
#   JBoss bind private IP address
# @param role
#   Role when operating mode is domain.
# @param user_cache
#   Boolean that determines if userCache is enabled
# @param tech_preview_features
#  List of technology Preview features to enable
# @param auto_deploy_exploded
#   Set if exploded deployements will be auto deployed
# @param auto_deploy_zipped
#   Set if zipped deployments will be auto deployed
# @param spi_deployments
#   Hash used to define keycloak::spi_deployment resources
# @param custom_config_content
#   Custom configuration content to be added to config.cli
# @param custom_config_source
#   Custom configuration source file to be added to config.cli
# @param master_address
#   IP address of the master in domain mode
# @param server_name
#   Server name in domain mode. Defaults to hostname.
# @param syslog
#   Enable syslog. Default false.
# @param syslog_app_name
#  Syslog app name. Default 'keycloak'.
# @param syslog_facility
#  Syslog facility. Default 'user-level'. See https://docs.jboss.org/author/display/AS72/Logging%20Configuration.html
# @param syslog_hostname
#  Syslog hostname of the server. Default $facts['fqdn'].
# @param syslog_level
#  Syslog level. Default 'INFO'. See https://docs.jboss.org/author/display/AS72/Logging%20Configuration.html
# @param syslog_port
#  The port the syslog server is listening on. Default '514'.
# @param syslog_server_address
#  The address of the syslog server. Default 'localhost'.
# @param syslog_format
#  Syslog format. Either 'RFC3164' or 'RFC5424' Default 'RFC3164'.
class keycloak (
  Boolean $manage_install       = true,
  String $version               = '12.0.4',
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]]
    $package_url                = undef,
  Optional[Stdlib::Absolutepath] $install_dir = undef,
  String $service_name          = 'keycloak',
  String $service_ensure        = 'running',
  Boolean $service_enable       = true,
  Boolean $service_hasstatus    = true,
  Boolean $service_hasrestart   = true,
  Stdlib::IP::Address $service_bind_address = '0.0.0.0',
  Stdlib::IP::Address $management_bind_address = '0.0.0.0',
  Optional[Variant[String, Array]] $java_opts = undef,
  Boolean $java_opts_append = true,
  Optional[String] $service_extra_opts = undef,
  Boolean $manage_user = true,
  String $user                  = 'keycloak',
  Stdlib::Absolutepath $user_shell = '/sbin/nologin',
  String $group                 = 'keycloak',
  Boolean $system_user          = true,
  Optional[Integer] $user_uid   = undef,
  Optional[Integer] $group_gid  = undef,
  String $admin_user            = 'admin',
  String $admin_user_password   = 'changeme',
  Optional[String] $wildfly_user = undef,
  Optional[String] $wildfly_user_password = undef,
  Boolean $manage_datasource = true,
  Enum['h2', 'mysql', 'oracle', 'postgresql'] $datasource_driver = 'h2',
  Optional[String] $datasource_host = undef,
  Optional[Integer] $datasource_port = undef,
  Optional[String] $datasource_url = undef,
  Optional[String] $datasource_xa_class = undef,
  String $datasource_dbname = 'keycloak',
  String $datasource_username = 'sa',
  String $datasource_password = 'sa',
  Optional[String] $datasource_package = undef,
  Optional[String] $datasource_jar_source = undef,
  Optional[String] $datasource_jar_filename = undef,
  Optional[String] $datasource_module_source = undef,
  String $mysql_database_charset = 'utf8',
  Boolean $proxy_https = false,
  Boolean $truststore = false,
  Hash $truststore_hosts = {},
  String $truststore_password = 'keycloak',
  Enum['WILDCARD', 'STRICT', 'ANY'] $truststore_hostname_verification_policy = 'WILDCARD',
  Integer $http_port = 8080,
  Integer $theme_static_max_age = 2592000,
  Boolean $theme_cache_themes = true,
  Boolean $theme_cache_templates = true,
  Hash $realms = {},
  Boolean $realms_merge = false,
  Hash $oidc_client_scopes = {},
  Boolean $oidc_client_scopes_merge = false,
  Hash $saml_client_scopes = {},
  Boolean $saml_client_scopes_merge = false,
  Hash $client_protocol_mappers = {},
  Hash $client_scopes = {},
  Boolean $client_scopes_merge = false,
  Hash $protocol_mappers = {},
  Boolean $protocol_mappers_merge = false,
  Hash $identity_providers = {},
  Boolean $identity_providers_merge = false,
  Hash $clients = {},
  Boolean $clients_merge = false,
  Hash $flows = {},
  Boolean $flows_merge = false,
  Hash $flow_executions = {},
  Hash $required_actions = {},
  Boolean $required_actions_merge = false,
  Hash $ldap_mappers = {},
  Boolean $ldap_mappers_merge = false,
  Hash $ldap_user_providers = {},
  Boolean $ldap_user_providers_merge = false,
  Boolean $flow_executions_merge = false,
  Boolean $with_sssd_support = false,
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]
    $libunix_dbus_java_source = 'https://github.com/keycloak/libunix-dbus-java/archive/libunix-dbus-java-0.8.0.tar.gz',
  Boolean $install_libunix_dbus_java_build_dependencies = true,
  Array $libunix_dbus_java_build_dependencies = [],
  Stdlib::Absolutepath $libunix_dbus_java_libdir = '/usr/lib64',
  String $jna_package_name = 'jna',
  Boolean $manage_sssd_config = true,
  Array $sssd_ifp_user_attributes = [],
  Boolean $restart_sssd = true,
  Optional[Stdlib::Absolutepath] $service_environment_file = undef,
  Enum['standalone', 'clustered', 'domain'] $operating_mode = 'standalone',
  Boolean $enable_jdbc_ping = false,
  Stdlib::IP::Address $jboss_bind_public_address = $facts['networking']['ip'],
  Stdlib::IP::Address $jboss_bind_private_address = $facts['networking']['ip'],
  Optional[Enum['master', 'slave']] $role = undef,
  Boolean $user_cache = true,
  Array $tech_preview_features = [],
  Boolean $auto_deploy_exploded = false,
  Boolean $auto_deploy_zipped = true,
  Hash $spi_deployments = {},
  Optional[String] $custom_config_content = undef,
  Optional[Variant[String, Array]] $custom_config_source = undef,
  Optional[Stdlib::Host] $master_address = undef,
  String $server_name = $facts['hostname'],
  Boolean $syslog = false,
  String $syslog_app_name = 'keycloak',
  String $syslog_facility = 'user-level',
  Stdlib::Host $syslog_hostname = $facts['fqdn'],
  String $syslog_level = 'INFO',
  Stdlib::Port $syslog_port = 514,
  Stdlib::Host $syslog_server_address = 'localhost',
  Enum['RFC3164', 'RFC5424'] $syslog_format = 'RFC3164',
) {

  if ! ($facts['os']['family'] in ['RedHat','Debian']) {
    fail("Unsupported osfamily: ${facts['os']['family']}, module ${module_name} only support osfamilies Debian and Redhat")
  }

  if $role and ! ($operating_mode == 'domain') {
    fail('Role can only be specified in domain operating mode')
  }

  if $operating_mode == 'domain' {
    unless $role {
      fail("Role not specified: in domain mode role needs to be specified. This needs to be either 'master' or 'slave'.")
    }
    unless $wildfly_user {
      fail('Wildfly user not specified: in domain mode Wildfly user needs to be specified.')
    }
    unless $wildfly_user_password {
      fail('Wildfly user password not specified: in domain, mode Wildfly user password needs to be specified.')
    }

    if $role == 'slave' and ! $master_address {
      fail('Master address not specified: in domain mode, master address needs to be specified for a slave.')
    }

    if $datasource_driver == 'h2' {
      fail("Invalid datasource driver for domain mode: ${datasource_driver}")
    }

    $wildfly_user_password_base64 = strip(base64('encode', $wildfly_user_password))
  }

  if versioncmp($version, '12.0.0') >= 0 {
    $download_url = pick($package_url, "https://github.com/keycloak/keycloak/releases/download/${version}/keycloak-${version}.tar.gz")
  } else {
    $download_url = pick($package_url, "https://downloads.jboss.org/keycloak/${version}/keycloak-${version}.tar.gz")
  }
  case $datasource_driver {
    'h2': {
      $datasource_connection_url = pick($datasource_url, "jdbc:h2:\${jboss.server.data.dir}/${datasource_dbname};AUTO_SERVER=TRUE")
      }
    'mysql': {
      $db_host = pick($datasource_host, 'localhost')
      $db_port = pick($datasource_port, 3306)
      $datasource_connection_url = pick($datasource_url, "jdbc:mysql://${db_host}:${db_port}/${datasource_dbname}")
      }
    'oracle': {
      $db_host = pick($datasource_host, 'localhost')
      $db_port = pick($datasource_port, 1521)
      $datasource_connection_url = pick($datasource_url, "jdbc:oracle:thin:@${db_host}:${db_port}:${datasource_dbname}")
      }
    'postgresql': {
      $db_host = pick($datasource_host, 'localhost')
      $db_port = pick($datasource_port, 5432)
      $datasource_connection_url = pick($datasource_url, "jdbc:postgresql://${db_host}:${db_port}/${datasource_dbname}")
      }
    default: {}
  }

  if ($datasource_driver == 'oracle') and ($datasource_jar_source == undef) {
    fail('Using Oracle RDBMS requires definition datasource_jar_source for Oracle JDBC driver. Refer to module documentation')
  }

  case $facts['os']['family'] {
    'RedHat': {
      if versioncmp($facts['os']['release']['major'], '8') >= 0 {
        $mysql_datasource_class = pick($datasource_xa_class, 'org.mariadb.jdbc.MariaDbDataSource')
        $mysql_jar_source = '/usr/lib/java/mariadb-java-client.jar'
        $postgresql_jar_source = '/usr/share/java/postgresql-jdbc/postgresql.jar'
      } else {
        $mysql_datasource_class = pick($datasource_xa_class, 'com.mysql.jdbc.jdbc2.optional.MysqlXADataSource')
        $mysql_jar_source = '/usr/share/java/mysql-connector-java.jar'
        $postgresql_jar_source = '/usr/share/java/postgresql-jdbc.jar'
      }
    }
    'Debian': {
      if ($facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['major'], '10') >= 0) or
      ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['major'], '20.04') >= 0) {
        $mysql_datasource_class = pick($datasource_xa_class, 'org.mariadb.jdbc.MariaDbDataSource')
        $mysql_jar_source = '/usr/share/java/mariadb-java-client.jar'
      } else {
        $mysql_datasource_class = pick($datasource_xa_class, 'com.mysql.jdbc.jdbc2.optional.MysqlXADataSource')
        $mysql_jar_source = '/usr/share/java/mysql-connector-java.jar'
      }
      $postgresql_jar_source = '/usr/share/java/postgresql.jar'
    }
    default: {
      # do nothing
    }
  }

  $install_base = pick($install_dir, "/opt/keycloak-${keycloak::version}")

  include ::java
  contain 'keycloak::install'
  contain "keycloak::datasource::${datasource_driver}"
  contain 'keycloak::config'
  contain 'keycloak::service'

  Class['::java']
  -> Class['keycloak::install']
  -> Class["keycloak::datasource::${datasource_driver}"]
  -> Class['keycloak::config']
  -> Class['keycloak::service']

  Class["keycloak::datasource::${datasource_driver}"]~>Class['keycloak::service']

  if $with_sssd_support {
    contain 'keycloak::sssd'
    Class['keycloak::sssd'] ~> Class['keycloak::service']
  }

  if $service_bind_address == '0.0.0.0' {
    $validator_keycloak_server = '127.0.0.1'
  } else {
    $validator_keycloak_server = $service_bind_address
  }

  keycloak_conn_validator { 'keycloak':
    keycloak_server => $validator_keycloak_server,
    keycloak_port   => $http_port,
    use_ssl         => false,
    timeout         => 60,
    test_url        => '/auth/realms/master/.well-known/openid-configuration',
    require         => Class['keycloak::service'],
  }

  include keycloak::resources

}
