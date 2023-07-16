# @summary Perform partialImport using CLI
#
# @example Perform partial import
#   keycloak::partial_import { 'mysettings':
#     realm              => 'test',
#     if_resource_exists => 'SKIP',
#     source             => 'puppet:///modules/profile/keycloak/mysettings.json',
#   }
#
# @param realm
#   The Keycloak Realm
# @param if_resource_exists
#   Behavior for when resources exist
# @param source
#   The import JSON source
# @param content
#   The import JSON content
# @param filename
#   The filename of the stored JSON
# @param require_realm
#   Determines whether to require the Keycloak_realm resource
# @param create_realm
#   Determines whether to define the Keycloak_realm resource
#
define keycloak::partial_import (
  String[1] $realm,
  Enum['FAIL','SKIP','OVERWRITE'] $if_resource_exists,
  Optional[Variant[Stdlib::Filesource, Stdlib::HTTPSUrl]] $source = undef,
  Optional[String[1]] $content = undef,
  String[1] $filename = $name,
  Boolean $require_realm = true,
  Boolean $create_realm = false,
) {
  include keycloak

  if ! $source and ! $content {
    fail("keycloak::partial_import[${name}] must specify either source or content")
  }
  if $source and $content {
    fail("keycloak::partial_import[${name}] specify either source or content, not both")
  }

  $file_path = "${keycloak::conf_dir}/${filename}.json"
  $command = join([
      "${keycloak::wrapper_path} create partialImport",
      "-r ${realm} -s ifResourceExists=${if_resource_exists} -o",
      "-f ${file_path}",
  ], ' ')

  file { $file_path:
    ensure  => 'file',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0600',
    source  => $source,
    content => $content,
    require => Class['keycloak::install'],
    notify  => Exec["partial-import-${name}"],
  }

  exec { "partial-import-${name}":
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    command     => "${command} || { rm -f ${file_path}; exit 1; }",
    logoutput   => true,
    refreshonly => true,
    require     => Keycloak_conn_validator['keycloak'],
  }

  if $require_realm {
    Keycloak_realm[$realm] -> Exec["partial-import-${name}"]
  }
  if $create_realm {
    keycloak_realm { $realm:
      ensure => 'present',
      before => Exec["partial-import-${name}"],
    }
  }
}
