#
define keycloak::realm (
  Boolean $remember_me = false,
  Boolean $login_with_email_allowed = true,
) {

  include keycloak
  realize Keycloak_conn_validator['keycloak']

  $config_dir = "${keycloak::install_base}/puppet"
  $config     = "${config_dir}/realm-${name}.json"
  $kcadm = "${keycloak::install_base}/bin/kcadm.sh"
  $auth = "--no-config --server http://localhost:8080/auth --realm master --user admin --password ${keycloak::admin_user_password}"

  # Template uses:
  # - $name
  # - $remember_me
  # - $login_with_email_allowed
  file { $config:
    ensure  => 'file',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0640',
    content => template('keycloak/realm.json.erb'),
    before  => [Exec["create-realm-${name}"], Exec["update-realm-${name}"]],
  }

  exec { "create-realm-${name}":
    command   => "${kcadm} create realms -f ${config} ${auth}",
    unless    => "${kcadm} get realms/${name} ${auth}",
    cwd       => $keycloak::install_base,
    user      => $keycloak::user,
    group     => $keycloak::group,
    logoutput => true,
    require   => Keycloak_conn_validator['keycloak'],
  }

  exec { "update-realm-${name}":
    command   => "${kcadm} update realms/${name} -f ${config} ${auth}",
    onlyif    => "${kcadm} get realms/${name} ${auth}",
    unless    => "${kcadm} get realms/${name} ${auth} | diff -w ${config} -",
    cwd       => $keycloak::install_base,
    user      => $keycloak::user,
    group     => $keycloak::group,
    logoutput => true,
    require   => Keycloak_conn_validator['keycloak'],
  }

}
