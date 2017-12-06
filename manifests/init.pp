# See README.md for more details.
class keycloak (
  String $version               = '3.0.0.Final',
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
  Integer $theme_static_max_age = 2592000,
  Boolean $theme_cache_themes = true,
  Boolean $theme_cache_templates = true,
  Hash $realms = {},
  Hash $client_templates = {},
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

  keycloak_conn_validator { 'keycloak':
    keycloak_server => 'localhost',
    keycloak_port   => '8080',
    use_ssl         => false,
    timeout         => 60,
    test_url        => '/auth/realms/master/.well-known/openid-configuration',
    require         => Class['keycloak::service'],
  }

  create_resources('keycloak_realm', $realms)
  create_resources('keycloak::client_template', $client_templates)

}
