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
# @param java_declare_method
#   How to declare the Java class within this module
#   The `include` value only includes the java class
#   The `class` method defines the Java class and passes necessary parameters
#   For RedHat base systems this defaults to `class`, other OSes default to `include`
# @param java_package
#   Java package name, only used when `java_declare_method` is `class`
# @param java_home
#   Java home path, only used when `java_declare_method` is `class`
# @param java_alternative_path
#   Java alternative path, only used when `java_declare_method` is `class`
# @param java_alternative
#   Java alternative, only used when `java_declare_method` is `class`
# @param service_name
#   Keycloak service name.
#   Default is `keycloak`.
# @param service_ensure
#   Keycloak service ensure property.
#   Default is `running`.
# @param service_enable
#   Keycloak service enable property.
#   Default is `true`.
# @param java_opts
#   Sets additional options to Java virtual machine environment variable.
# @param start_command
#   The start command to use to run Keycloak
# @param service_extra_opts
#   Additional options added to the end of the service command-line.
# @param service_environment_file
#   Path to the file with environment variables for the systemd service
# @param configs
#   Define additional configs for keycloak.conf
# @param extra_configs
#   Additional configs for keycloak.conf
# @param hostname
#   hostname to set in keycloak.conf
#   Set to `unset` or `UNSET` to not define this in keycloak.conf
# @param http_enabled
#   Whether to enable HTTP
# @param http_host
#   HTTP host
# @param http_port
#   HTTP port
# @param https_port
#   HTTPS port
# @param http_relative_path
#   Set the path relative to '/' for serving resources. The path must start with a '/'.
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
# @param manage_db
#   Boolean that determines if configured database will be managed.
# @param manage_db_server
#   Include the DB server class for postgres, mariadb or mysql
# @param db
#   Database driver to use for Keycloak.
# @param db_url_host
#   Database host.
# @param db_url_port
#   Database port.
# @param db_url
#   Database url.
# @param db_url_database
#   Database name.
# @param db_username
#   Database user name.
# @param db_password
#   Database user password.
# @param db_charset
#   MySQL and MariaDB database charset
# @param db_collate
#   MySQL and MariaDB database collate
# @param features
#   Keycloak features to enable
# @param features_disabled
#   Keycloak features to disable
# @param truststore
#   Boolean that sets if truststore should be used.
#   Default is `false`.
# @param truststore_hosts
#   Hash that is used to define `keycloak::turststore::host` resources.
#   Default is `{}`.
# @param truststore_password
#   Truststore password.
#   Default is `keycloak`.
# @param proxy
#   Type of proxy to use for Keycloak
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
# @param spi_deployments
#   Hash used to define keycloak::spi_deployment resources
# @param providers_purge
#   Purge the providers directory of unmanaged SPIs
# @param custom_config_content
#   Custom configuration content to be added to keycloak.conf
# @param custom_config_source
#   Custom configuration source file to be added to keycloak.conf
# @param validator_test_url
#   The URL path for validator testing
#   Only necessary to set if the URL path to Keycloak is modified
class keycloak (
  Boolean $manage_install       = true,
  String $version               = '19.0.3',
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $package_url= undef,
  Optional[Stdlib::Absolutepath] $install_dir = undef,
  Enum['include','class'] $java_declare_method = 'class',
  String[1] $java_package = 'java-11-openjdk-devel',
  Stdlib::Absolutepath $java_home = '/usr/lib/jvm/java-11-openjdk',
  Stdlib::Absolutepath $java_alternative_path = '/usr/lib/jvm/java-11-openjdk/bin/java',
  String[1] $java_alternative = '/usr/lib/jvm/java-11-openjdk/bin/java',
  String $service_name          = 'keycloak',
  String $service_ensure        = 'running',
  Boolean $service_enable       = true,
  Optional[Variant[String, Array]] $java_opts = undef,
  Enum['start','start-dev'] $start_command = 'start',
  Optional[String] $service_extra_opts = undef,
  Optional[Stdlib::Absolutepath] $service_environment_file = undef,
  Keycloak::Configs $configs = {},
  Hash[String, Variant[String[1],Boolean,Array]] $extra_configs = {},
  Variant[Stdlib::Host, Enum['unset','UNSET']] $hostname = $facts['networking']['fqdn'],
  Boolean $http_enabled = true,
  Stdlib::IP::Address $http_host = '0.0.0.0',
  Stdlib::Port $http_port = 8080,
  Stdlib::Port $https_port = 8443,
  Pattern[/^\/.*/] $http_relative_path = '/',
  Boolean $manage_user = true,
  String $user                  = 'keycloak',
  Stdlib::Absolutepath $user_shell = '/sbin/nologin',
  String $group                 = 'keycloak',
  Boolean $system_user          = true,
  Optional[Integer] $user_uid   = undef,
  Optional[Integer] $group_gid  = undef,
  String $admin_user            = 'admin',
  String $admin_user_password   = 'changeme',
  Boolean $manage_db = true,
  Boolean $manage_db_server = true,
  Enum['dev-file', 'dev-mem', 'mariadb', 'mysql', 'oracle', 'postgres'] $db = 'dev-file',
  Optional[Stdlib::Host] $db_url_host = undef,
  Optional[Stdlib::Port] $db_url_port = undef,
  Optional[String[1]] $db_url = undef,
  String[1] $db_url_database = 'keycloak',
  String[1] $db_username = 'keycloak',
  String[1] $db_password = 'changeme',
  String $db_charset = 'utf8',
  String $db_collate = 'utf8_general_ci',
  Optional[Array[String[1]]] $features = undef,
  Optional[Array[String[1]]] $features_disabled = undef,
  Boolean $truststore = false,
  Hash $truststore_hosts = {},
  String $truststore_password = 'keycloak',
  Enum['edge','reencrypt','passthrough','none'] $proxy = 'none',
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
  Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl] $libunix_dbus_java_source = 'https://github.com/keycloak/libunix-dbus-java/archive/libunix-dbus-java-0.8.0.tar.gz',
  Boolean $install_libunix_dbus_java_build_dependencies = true,
  Array $libunix_dbus_java_build_dependencies = [],
  Stdlib::Absolutepath $libunix_dbus_java_libdir = '/usr/lib64',
  String $jna_package_name = 'jna',
  Boolean $manage_sssd_config = true,
  Array $sssd_ifp_user_attributes = [],
  Boolean $restart_sssd = true,
  Hash $spi_deployments = {},
  Boolean $providers_purge = true,
  Optional[String] $custom_config_content = undef,
  Optional[Variant[String, Array]] $custom_config_source = undef,
  String $validator_test_url = '/realms/master/.well-known/openid-configuration',
) {
  if ! ($facts['os']['family'] in ['RedHat','Debian']) {
    fail("Unsupported osfamily: ${facts['os']['family']}, module ${module_name} only support osfamilies Debian and Redhat")
  }

  $download_url = pick($package_url, "https://github.com/keycloak/keycloak/releases/download/${version}/keycloak-${version}.tar.gz")

  $install_base = pick($install_dir, "/opt/keycloak-${keycloak::version}")
  $admin_env = "${install_base}/conf/admin.env"
  $truststore_file = "${install_base}/conf/truststore.jks"
  $tmp_dir = "${install_base}/tmp"
  $providers_dir = "${install_base}/providers"

  $default_config = {
    'hostname' => $hostname,
    'http-enabled' => $http_enabled,
    'http-host' => $http_host,
    'http-port' => $http_port,
    'https-port' => $https_port,
    'http-relative-path' => $http_relative_path,
    'db' => $db,
    'db-url-host' => $db_url_host,
    'db-url-port' => $db_url_port,
    'db-url' => $db_url,
    'db-url-database' => $db_url_database,
    'db-username' => $db_username,
    'db-password' => $db_password,
    'features' => $features,
    'features-disabled' => $features_disabled,
    'proxy' => $proxy,
  }.filter |$key, $value| { $value =~ NotUndef and ! ($value in ['unset', 'UNSET']) }
  if $truststore {
    $truststore_configs = {
      'https-trust-store-file' => $truststore_file,
      'https-trust-store-password' => $truststore_password,
    }
  } else {
    $truststore_configs = {}
  }
  $config = $default_config + $truststore_configs + $configs + $extra_configs

  if $config['http-enabled'] {
    $wrapper_protocol = 'http'
    $wrapper_port = $config['http-port']
    $validator_port = $config['http-port']
    $validator_ssl = false
    if $config['http-host'] in ['0.0.0.0', '127.0.0.1'] {
      $wrapper_address = 'localhost'
      $validator_server = 'localhost'
    } else {
      $wrapper_address = $config['http-host']
      $validator_server = $config['http-host']
    }
  } else {
    if $config['hostname'] in ['unset', 'UNSET'] {
      $hostname = $facts['networking']['fqdn']
    } else {
      $hostname = $config['hostname']
    }
    $wrapper_protocol = 'https'
    $wrapper_port = $config['https-port']
    $wrapper_address = $hostname
    $validator_port = $config['https-port']
    $validator_server = $hostname
    $validator_ssl = true
  }
  $wrapper_server = "${wrapper_protocol}://${wrapper_address}:${wrapper_port}${config['http-relative-path']}"

  $service_start = [
    "${install_base}/bin/kc.sh",
    $start_command,
    $service_extra_opts,
  ].filter |$s| { $s =~ NotUndef }
  $service_start_cmd = join($service_start, ' ')

  if $java_declare_method == 'include' {
    contain java
  } else {
    class { 'java':
      package               => $java_package,
      java_home             => $java_home,
      java_alternative_path => $java_alternative_path,
      java_alternative      => $java_alternative,
    }
  }

  contain 'keycloak::install'
  contain 'keycloak::config'
  contain 'keycloak::service'

  Class['java']
  -> Class['keycloak::install']
  -> Class['keycloak::config']
  -> Class['keycloak::service']

  if $db in ['mysql','mariadb','postgres'] {
    contain "keycloak::db::${db}"
    Class["keycloak::db::${db}"] ~> Class['keycloak::service']
  }

  if $with_sssd_support {
    contain 'keycloak::sssd'
    Class['keycloak::sssd'] ~> Class['keycloak::service']
  }

  keycloak_conn_validator { 'keycloak':
    keycloak_server => $validator_server,
    keycloak_port   => $validator_port,
    use_ssl         => $validator_ssl,
    timeout         => 60,
    test_url        => $validator_test_url,
    require         => Class['keycloak::service'],
  }

  include keycloak::resources
}
