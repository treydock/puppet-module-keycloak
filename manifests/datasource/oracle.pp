# @summary Manage Oracle datasource
#
# @api private
#
class keycloak::datasource::oracle {
  assert_private()

  $module_source = pick($keycloak::datasource_module_source, 'puppet:///modules/keycloak/database/oracle/module.xml')
  $module_dir = "${keycloak::install_base}/modules/system/layers/keycloak/org/oracle/main"

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

  file { "${module_dir}/oracle.jar":
    ensure => 'file',
    source => $keycloak::datasource_jar_source,
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
