# Private class.
class keycloak::config {
  assert_private()

  $_add_user_keycloak_cmd = "${keycloak::install_dir}/keycloak-${keycloak::version}/bin/add-user-keycloak.sh"
  $_add_user_keycloak_args = "--user ${keycloak::admin_user} --password ${keycloak::admin_user_password} --realm master"
  $_add_user_keycloak_state = "${keycloak::install_dir}/keycloak-${keycloak::version}/.create-keycloak-admin"
  exec { 'create-keycloak-admin':
    command => "${_add_user_keycloak_cmd} ${_add_user_keycloak_args} && touch ${_add_user_keycloak_state}",
    creates => $_add_user_keycloak_state,
  }

  file { "${keycloak::install_dir}/keycloak-${keycloak::version}/config.cli":
    ensure  => 'file',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0600',
    content => template('keycloak/config.cli.erb'),
    notify  => Exec['jboss-cli.sh --file=config.cli'],
  }

  exec { 'jboss-cli.sh --file=config.cli':
    command     => "${keycloak::install_dir}/keycloak-${keycloak::version}/bin/jboss-cli.sh --file=config.cli",
    cwd         => "${keycloak::install_dir}/keycloak-${keycloak::version}",
    user        => $keycloak::user,
    group       => $keycloak::group,
    refreshonly => true,
    logoutput   => true,
  }

}
