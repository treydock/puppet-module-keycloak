# summary Manage Keycloak
#
# @example
#   include ::keycloak
#
# @param version
#   Version of Keycloak to install and manage.
#   Default is `3.4.1.Final`.
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
# @param user
#   Keycloak user name.
#   Default is `keycloak`.
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
#   Valid values are `h2` and `mysql`.
#   Default is `h2`.
# @param datasource_host
#   Datasource host.
#   Only used when datasource_driver is `mysql`.
#   Default is `localhost` for MySQL.
# @param datasource_port
#   Datasource port.
#   Only used when datasource_driver is `mysql`.
#   Default is `3306` for MySQL.
# @param datasource_dbname
#   Datasource database name.
#   Default is `keycloak`.
# @param datasource_username
#   Datasource user name.
#   Default is `sa`.
# @param datasource_password
#   Datasource user password.
#   Default is `sa`.
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
# @param client_templates
#   Hash that is used to define keycloak::client_template resources.
#   Default is `{}`.
# @param oracle_jar_file
#   Oracle JDBC driver to use. Only use if $datasource_driver is set to oracle
#   Default is not defined
# @param oracle_jar_source
#   Source for Oracle JDBC driver - could be puppet link or local file on the node. Only use if $datasource_driver is set to oracle
#   Default is not set
# @param https 
#   Defines if https should be configured.
#   Default is false.
# @param ssl_keystore_file 
#   Name of the keystore file. Will be placed in configuration folder in Keycloak installation
#   Default is not set.
# @param ssl_keystore_source 
#   Path to the keystore to be copied from.
#   Default is not set
# @param ssl_keystore_pass 
#   Password to SSL keystore.
#   Default is not set.
# @param https_port 
#   Port for HTTPS connection.
#   Default is 8443
#
class keycloak (
  String $version               = '3.4.1.Final',
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]]
    $package_url                = undef,
  Stdlib::Absolutepath $install_dir = '/opt',
  String $service_name          = $keycloak::params::service_name,
  String $service_ensure        = 'running',
  Boolean $service_enable       = true,
  Boolean $service_hasstatus    = $keycloak::params::service_hasstatus,
  Boolean $service_hasrestart   = $keycloak::params::service_hasrestart,
  Variant[String, Array] $service_java_opts = $keycloak::params::service_java_opts,
  String $user                  = 'keycloak',
  String $group                 = 'keycloak',
  Optional[Integer] $user_uid   = undef,
  Optional[Integer] $group_gid  = undef,
  String $admin_user            = 'admin',
  String $admin_user_password   = 'changeme',
  Boolean $manage_datasource = true,
  Enum['h2', 'mysql'] $datasource_driver = 'h2',
  Optional[String] $datasource_host = undef,
  Optional[Integer] $datasource_port = undef,
  String $datasource_dbname = 'keycloak',
  String $datasource_username = 'sa',
  String $datasource_password = 'sa',
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
  Hash $client_templates = {},
  Optional[String] $oracle_jar_file = undef,
  Optional[String] $oracle_jar_source = undef,
  Boolean $https = false,
  Integer $https_port = 8443,
  Optional[String] $ssl_keystore_file = undef,
  Optional[String] $ssl_keystore_source = undef,
  Optional[String] $ssl_keystore_pass = undef,

) inherits keycloak::params {

  $download_url = pick($package_url, "https://downloads.jboss.org/keycloak/${version}/keycloak-${version}.tar.gz")
  case $datasource_driver {
    'h2': {
      $datasource_connection_url = "jdbc:h2:\${jboss.server.data.dir}/${datasource_dbname};AUTO_SERVER=TRUE"
    }
    'mysql': {
      $db_host = pick($datasource_host, 'localhost')
      $db_port = pick($datasource_port, 3306)
      $datasource_connection_url = "jdbc:mysql://${db_host}:${db_port}/${datasource_dbname}"
    }
    default: {}
  }

  if ($datasource_driver == 'oracle') and (($oracle_jar_file == undef) or ($oracle_jar_source == undef)) {
    fail('Using Oracle RDBMS requires definition of jar_file and jar_source for Oracle JDBC driver. Refer to module documentation')
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

# Keycloak conn validator is active only for HTTP connection, as HTTPS connection works only with Puppet certs and not custom keystore (Ticket SERVER-1543)
  if ! $keycloak::https {
    keycloak_conn_validator { 'keycloak':
      keycloak_server => localhost,
      keycloak_port   => $http_port,
      use_ssl         => false,
      timeout         => 60,
      test_url        => '/auth/realms/master/.well-known/openid-configuration',
      require         => Class['keycloak::service'],
    }
  }

  create_resources('keycloak_realm', $realms)
  create_resources('keycloak::client_template', $client_templates)
}
