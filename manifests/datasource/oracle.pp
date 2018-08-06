# Private class.
class keycloak::datasource::oracle (
  $jar_source    = 'puppet:///modules/keycloak/database/oracle/ojdbc8.jar',
  $module_source = 'puppet:///modules/keycloak/database/oracle/module.xml',
) {
  assert_private()

  $module_dir = "${keycloak::install_dir}/keycloak-${keycloak::version}/modules/system/layers/keycloak/org/oracle/main"

  exec { "mkdir -p ${module_dir}":
    path    => '/usr/bin:/bin',
    creates => $module_dir,
    user    => $keycloak::user,
    group   => $keycloak::group,
  }
  -> file { $module_dir:
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0755',
  }
  file { "${$module_dir}/ojdbc8.jar":
    ensure => 'file',
    source => $jar_source,
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0644',
  }
  file { "${$module_dir}/module.xml":
    ensure => 'file',
    source => $module_source,
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0644',
  }
}
