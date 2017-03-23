#
define keycloak::client (
  String $realm,
  Array $redirect_uris,
  String $client_template,
  Optional[String] $secret,
) {

  include keycloak
  realize Keycloak_conn_validator['keycloak']
  Keycloak::Realm <| title == $realm |> -> Keycloak::Client[$name]
  Keycloak::Client_template <| title == $client_template |> -> Keycloak::Client[$name]

  $config_dir = "${keycloak::install_base}/puppet"
  $config     = "${config_dir}/client-${name}.json"
  $kcadm = "${keycloak::install_base}/bin/kcadm.sh"
  $auth = "--no-config --server http://localhost:8080/auth --realm master --user admin --password ${keycloak::admin_user_password}"

  # Template uses:
  # - $name
  # - $redirect_uris
  # - $client_template
  file { $config:
    ensure  => 'file',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0640',
    content => template('keycloak/client.json.erb'),
    before  => [Exec["create-client-${name}"], Exec["update-client-${name}"]],
  }

  exec { "create-client-${name}":
    command   => "${kcadm} create clients -r ${realm} -f ${config} ${auth}",
    unless    => "${kcadm} get clients/${name} -r ${realm} ${auth}",
    cwd       => $keycloak::install_base,
    user      => $keycloak::user,
    group     => $keycloak::group,
    logoutput => true,
    require   => Keycloak_conn_validator['keycloak'],
  }

  exec { "update-client-${name}":
    command     => "${kcadm} update clients/${name} -r ${realm} -f ${config} ${auth}",
    onlyif      => "${kcadm} get clients/${name} -r ${realm} ${auth}",
    #unless    => "${kcadm} get clients/${name} ${auth} | diff -w ${config} -",
    cwd         => $keycloak::install_base,
    user        => $keycloak::user,
    group       => $keycloak::group,
    logoutput   => true,
    require     => Keycloak_conn_validator['keycloak'],
    refreshonly => true,
    subscribe   => File[$config],
  }

}
