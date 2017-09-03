#
define keycloak::user_federation::ldap_mapper (
  String $realm,
  String $ldap,
  String $ldap_attribute,
  String $resource_name = $name,
  Enum['user-attribute-ldap-mapper', 'full-name-ldap-mapper'] $type = 'user-attribute-ldap-mapper',
  Boolean $is_mandatory_in_ldap = false,
  Boolean $read_only = true,
  Boolean $write_only = false,
  Optional[String] $model_attribute = undef,
  ) {

  include keycloak
  realize Keycloak_conn_validator['keycloak']
  Keycloak::Realm <| title == $realm |> -> Keycloak::User_federation::Ldap_mapper[$name]
  Keycloak_ldap_user_provider <| title == $ldap |> -> Keycloak::User_federation::Ldap_mapper[$name]

  $id = fqdn_uuid($name)
  $config_dir = "${keycloak::install_base}/puppet"
  $config     = "${config_dir}/ldap-mapper-${name}.json"
  $kcadm = "${keycloak::install_base}/bin/kcadm.sh"
  $auth = "--no-config --server http://localhost:8080/auth --realm master --user admin --password ${keycloak::admin_user_password}"

  # Template uses:
  file { $config:
    ensure  => 'file',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0640',
    content => template('keycloak/ldap-mapper.json.erb'),
    before  => [Exec["create-ldap-mapper-${name}"], Exec["update-ldap-mapper-${name}"]],
  }

  exec { "create-ldap-mapper-${name}":
    command   => "${kcadm} create components -r ${realm} -f ${config} ${auth}",
    unless    => "${kcadm} get components/${id} -r ${realm} ${auth}",
    cwd       => $keycloak::install_base,
    user      => $keycloak::user,
    group     => $keycloak::group,
    logoutput => true,
    require   => Keycloak_conn_validator['keycloak'],
  }

  exec { "update-ldap-mapper-${name}":
    command     => "${kcadm} update components/${id} -r ${realm} -f ${config} ${auth}",
    onlyif      => "${kcadm} get components/${id} -r ${realm} ${auth}",
    #unless      => "/bin/bash -c '${kcadm} get components/${name} -r ${realm} ${auth} | grep -v 'lastSync' | sort | diff -w -u <( sort ${config} ) -'",
    cwd         => $keycloak::install_base,
    user        => $keycloak::user,
    group       => $keycloak::group,
    logoutput   => true,
    require     => Keycloak_conn_validator['keycloak'],
    refreshonly => true,
    subscribe   => File[$config],
  }

}
