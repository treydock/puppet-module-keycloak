# Private class.
class keycloak::datasource::oracle (
  $jar_file      = $keycloak::oracle_jar_file,
  $jar_source    = $keycloak::oracle_jar_source,
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

  if ($jar_file != undef) and ($jar_source != undef) {
    file { "${$module_dir}/${jar_file}":
      ensure => 'file',
      source => $jar_source,
      owner  => $keycloak::user,
      group  => $keycloak::group,
      mode   => '0644',
    }
  }
  else {
    fail('Using Oracle RDBMS requires definition of jar_file and jar_source for Oracle JDBC driver. Refer to module documentation')
  }

  file { "${$module_dir}/module.xml":
    ensure => 'file',
    source => $module_source,
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0644',
  }
}
