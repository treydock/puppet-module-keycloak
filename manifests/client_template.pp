#
define keycloak::client_template (
  String $realm,
  String $resource_name = $name,
  Enum['openid-connect'] $protocol = 'openid-connect',
  Boolean $full_scope_allowed = true,
) {

  include keycloak
  realize Keycloak_conn_validator['keycloak']
  Keycloak::Realm <| title == $realm |> -> Keycloak::Client_template[$name]
  Keycloak::Client_template[$name] -> Keycloak_client <| |>

  $config_dir = "${keycloak::install_base}/puppet"
  $config     = "${config_dir}/client-template-${name}.json"
  $kcadm = "${keycloak::install_base}/bin/kcadm.sh"
  $auth = "--no-config --server http://localhost:8080/auth --realm master --user admin --password ${keycloak::admin_user_password}"

  # Template uses:
  # - $protocol
  # - $full_scope_allowed
  file { $config:
    ensure  => 'file',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0640',
    content => template('keycloak/client-template.json.erb'),
    before  => [Exec["create-client-template-${name}"], Exec["update-client-template-${name}"]],
  }

  exec { "create-client-template-${name}":
    command   => "${kcadm} create client-templates -r ${realm} -f ${config} ${auth}",
    unless    => "${kcadm} get client-templates/${name} -r ${realm} ${auth}",
    cwd       => $keycloak::install_base,
    user      => $keycloak::user,
    group     => $keycloak::group,
    logoutput => true,
    require   => Keycloak_conn_validator['keycloak'],
  }

  exec { "update-client-template-${name}":
    command     => "${kcadm} update client-templates/${name} -r ${realm} -f ${config} ${auth}",
    onlyif      => "${kcadm} get client-templates/${name} -r ${realm} ${auth}",
    #unless    => "${kcadm} get client-templates/${name} ${auth} | diff -w ${config} -",
    cwd         => $keycloak::install_base,
    user        => $keycloak::user,
    group       => $keycloak::group,
    logoutput   => true,
    require     => Keycloak_conn_validator['keycloak'],
    refreshonly => true,
    subscribe   => File[$config],
  }

}
