# @summary Manage postgresql datasource
#
# @api private
class keycloak::datasource::postgresql (
  $jar_file      = $keycloak::postgresql_jar_file,
  $jar_source    = $keycloak::postgresql_jar_source,
  $module_source = 'keycloak/database/postgresql/module.xml.erb',
) {
  assert_private()

  $module_dir = "${keycloak::install_dir}/keycloak-${keycloak::version}/modules/system/layers/keycloak/org/postgresql/main"

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

  file { "${module_dir}/${jar_file}":
    ensure => 'file',
    source => $jar_source,
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0644',
  }

  file { "${$module_dir}/module.xml":
    ensure  => 'file',
    content => template($module_source),
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0644',
  }
}
