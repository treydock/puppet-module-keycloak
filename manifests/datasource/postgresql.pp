# @summary Manage postgresql datasource
#
# @api private
class keycloak::datasource::postgresql {
  assert_private()

  $jar_source = pick($keycloak::datasource_jar_source, $keycloak::postgresql_jar_source)
  $module_source = pick($keycloak::datasource_module_source, 'puppet:///modules/keycloak/database/postgresql/module.xml')
  $module_dir = "${keycloak::install_dir}/keycloak-${keycloak::version}/modules/system/layers/keycloak/org/postgresql/main"

  include ::postgresql::lib::java

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

  file { "${module_dir}/postgresql-jdbc.jar":
    ensure  => 'file',
    source  => $jar_source,
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0644',
    require => Class['postgresql::lib::java'],
  }

  file { "${$module_dir}/module.xml":
    ensure => 'file',
    source => $module_source,
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0644',
  }

  if $keycloak::manage_datasource {
    include ::postgresql::server
    postgresql::server::db { $keycloak::datasource_dbname:
      user     => $keycloak::datasource_username,
      password => postgresql_password($keycloak::datasource_username, $keycloak::datasource_password),
    }
  }
}
