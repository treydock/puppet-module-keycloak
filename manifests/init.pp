# @summary Manage Keycloak
#
# @example
#   include ::keycloak
#
# @param manage_install
#   Install Keycloak from upstream Keycloak tarball.
#   Set to false to manage installation of Keycloak outside
#   this module and set $install_dir and $version to match.
#   Defaults to true.
# @param version
#   Version of Keycloak to install and manage.
# @param package_url
#   URL of the Keycloak download.
#   Default is based on version.
# @param install_dir
#   Parent directory of where to install Keycloak.
#   Default is `/opt`.
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
# @param service_java_opts
#   Sets additional options to Java virtual machine environment variable.
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
# @param admin_user
#   Keycloak administrative username.
#   Default is `admin`.
# @param admin_user_password
#   Keycloak administrative user password.
#   Default is `changeme`.
# @param manage_datasource
#   Boolean that determines if configured datasource will be managed.
#   Only applies when `datasource_driver` is `mysql`.
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
# @param datasource_jar_source
#   Source for datasource JDBC driver - could be puppet link or local file on the node.
#   Default is dependent on value for `datasource_driver`.
#   This parameter is required if `datasource_driver` is `oracle`.
# @param datasource_module_source
#   Source for datasource module.xml. Default depends on `datasource_driver`.
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
#
class keycloak (
  Boolean $manage_install       = true,
  String $version               = '6.0.1',
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]]
    $package_url                = undef,
  Stdlib::Absolutepath $install_dir = '/opt',
  String $service_name          = 'keycloak',
  String $service_ensure        = 'running',
  Boolean $service_enable       = true,
  Boolean $service_hasstatus    = true,
  Boolean $service_hasrestart   = true,
  Stdlib::IP::Address $service_bind_address = '0.0.0.0',
  Optional[Variant[String, Array]]
    $service_java_opts = undef,
  Optional[String] $service_extra_opts = undef,
  Boolean $manage_user = true,
  String $user                  = 'keycloak',
  Stdlib::Absolutepath $user_shell = '/sbin/nologin',
  String $group                 = 'keycloak',
  Optional[Integer] $user_uid   = undef,
  Optional[Integer] $group_gid  = undef,
  String $admin_user            = 'admin',
  String $admin_user_password   = 'changeme',
  Boolean $manage_datasource = true,
  Enum['h2', 'mysql', 'oracle', 'postgresql'] $datasource_driver = 'h2',
  Optional[String] $datasource_host = undef,
  Optional[Integer] $datasource_port = undef,
  Optional[String] $datasource_url = undef,
  String $datasource_dbname = 'keycloak',
  String $datasource_username = 'sa',
  String $datasource_password = 'sa',
  Optional[String] $datasource_jar_source = undef,
  Optional[String] $datasource_module_source = undef,
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
  Hash $client_scopes = {},
  Boolean $client_scopes_merge = false,
  Hash $protocol_mappers = {},
  Boolean $protocol_mappers_merge = false,
  Hash $identity_providers = {},
  Boolean $identity_providers_merge = false,
  Hash $clients = {},
  Boolean $clients_merge = false,
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
  Enum['standalone', 'clustered'] $operating_mode = 'standalone',
) {

  if ! $facts['os']['family'] in ['RedHat','Debian'] {
    fail("Unsupported osfamily: ${facts['os']['family']}, module ${module_name} only support osfamilies Debian and Redhat")
  }

  $download_url = pick($package_url, "https://downloads.jboss.org/keycloak/${version}/keycloak-${version}.tar.gz")
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
      $mysql_jar_source = '/usr/share/java/mysql-connector-java.jar'
      $postgresql_jar_source = '/usr/share/java/postgresql-jdbc.jar'
    }
    'Debian': {
      $mysql_jar_source = '/usr/share/java/mysql-connector-java.jar'
      $postgresql_jar_source = '/usr/share/java/postgresql.jar'
    }
    default: {
      # do nothing
    }
  }

  $install_base = "${keycloak::install_dir}/keycloak-${keycloak::version}"

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

  keycloak_conn_validator { 'keycloak':
    keycloak_server => 'localhost',
    keycloak_port   => $http_port,
    use_ssl         => false,
    timeout         => 60,
    test_url        => '/auth/realms/master/.well-known/openid-configuration',
    require         => Class['keycloak::service'],
  }

  include keycloak::resources

}
