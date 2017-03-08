# See README.md for more details.
class keycloak (
  String $version               = '2.5.4.Final',
  Optional[String] $package_url = undef,
  String $install_dir           = '/opt',
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
  Enum['default', 'mysql'] $jdbc_driver = 'default',
) inherits keycloak::params {

  $download_url = pick($package_url, "https://downloads.jboss.org/keycloak/${version}/keycloak-${version}.tar.gz")

  include ::java
  contain 'keycloak::install'
  contain "keycloak::database::${jdbc_driver}"
  contain 'keycloak::config'
  contain 'keycloak::service'

  Class['::java']->
  Class['keycloak::install']->
  Class["keycloak::database::${jdbc_driver}"]->
  Class['keycloak::config']~>
  Class['keycloak::service']

  Class["keycloak::database::${jdbc_driver}"]~>Class['keycloak::service']

}
