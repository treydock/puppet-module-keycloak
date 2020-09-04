# @summary Manage Oracle datasource
#
# @api private
#
class keycloak::datasource::oracle {
  assert_private()

  $jar_filename = pick($keycloak::datasource_jar_filename, 'ojdbc8.jar')
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

  file { "${module_dir}/${jar_filename}":
    ensure => 'file',
    source => $keycloak::datasource_jar_source,
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0644',
  }

  $module_xml_defaults = {
    ensure => 'file',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0644',
  }
  if $keycloak::datasource_module_source {
    $module_xml_options = {
      source => $keycloak::datasource_module_source,
    }
  } else {
    $module_xml_options = {
      content => template('keycloak/database/oracle/module.xml.erb'),
    }
  }
  file { "${$module_dir}/module.xml":
    * => $module_xml_defaults + $module_xml_options,
  }
}
