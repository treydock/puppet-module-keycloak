#
define keycloak::user_federation::ldap (
  String $realm,
  String $user_dn,
  String $connection_url,
  Integer $priority = 0,
  Array $user_objectclasses = ['inetOrgPerson', 'organizationalPerson'],
  String $username_ldap_attribute = 'uid',
  String $rdn_ldap_attribute = 'uid',
  String $uuid_ldap_attribute = 'entryUUID',
  Enum['none', 'simple'] $auth_type = 'none',
  Enum['READ_ONLY', 'WRITABLE', 'UNSYNCED'] $edit_mode = 'READ_ONLY',
  Enum['ad', 'rhds', 'tivoli', 'eDirectory', 'other'] $vendor = 'other',
) {

  include keycloak
  realize Keycloak_conn_validator['keycloak']
  Keycloak::Realm[$realm] -> Keycloak::User_federation::Ldap[$name]

  $config_dir = "${keycloak::install_base}/puppet"
  $config     = "${config_dir}/ldap-${name}.json"
  $kcadm = "${keycloak::install_base}/bin/kcadm.sh"
  $auth = "--no-config --server http://localhost:8080/auth --realm master --user admin --password ${keycloak::admin_user_password}"

  # Template uses:
  file { $config:
    ensure  => 'file',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0640',
    content => template('keycloak/ldap.json.erb'),
    before  => [Exec["create-ldap-${name}"], Exec["update-ldap-${name}"]],
  }

  exec { "create-ldap-${name}":
    command   => "${kcadm} create components -r ${realm} -f ${config} ${auth}",
    unless    => "${kcadm} get components/${name} -r ${realm} ${auth}",
    cwd       => $keycloak::install_base,
    user      => $keycloak::user,
    group     => $keycloak::group,
    logoutput => true,
    require   => Keycloak_conn_validator['keycloak'],
  }

  exec { "update-ldap-${name}":
    command     => "${kcadm} update components/${name} -r ${realm} -f ${config} ${auth}",
    onlyif      => "${kcadm} get components/${name} -r ${realm} ${auth}",
    unless      => "/bin/bash -c '${kcadm} get components/${name} -r ${realm} ${auth} | grep -v 'lastSync' | sort | diff -w -u <( sort ${config} ) -'",
    cwd         => $keycloak::install_base,
    user        => $keycloak::user,
    group       => $keycloak::group,
    logoutput   => true,
    require     => Keycloak_conn_validator['keycloak'],
    refreshonly => true,
    subscribe   => File[$config],
  }

}
