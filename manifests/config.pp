# Private class.
class keycloak::config {
  assert_private()

  file { '/opt/keycloak':
    ensure => 'link',
    target => $keycloak::install_base
  }

  # Template uses:
  # - $keycloak::install_base
  # - $keycloak::admin_user
  # - $keycloak::admin_user_password
  file { 'kcadm-wrapper.sh':
    ensure    => 'file',
    path      => "${keycloak::install_base}/bin/kcadm-wrapper.sh",
    owner     => $keycloak::user,
    group     => $keycloak::group,
    mode      => '0750',
    content   => template('keycloak/kcadm-wrapper.sh.erb'),
    show_diff => false,
  }

  $_add_user_keycloak_cmd = "${keycloak::install_base}/bin/add-user-keycloak.sh"
  $_add_user_keycloak_args = "--user ${keycloak::admin_user} --password ${keycloak::admin_user_password} --realm master"
  $_add_user_keycloak_state = "${keycloak::install_base}/.create-keycloak-admin-${keycloak::datasource_driver}"
  exec { 'create-keycloak-admin':
    command => "${_add_user_keycloak_cmd} ${_add_user_keycloak_args} && touch ${_add_user_keycloak_state}",
    creates => $_add_user_keycloak_state,
    notify  => Class['keycloak::service'],
  }

  file { "${keycloak::install_base}/standalone/configuration":
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0750',
  }

  file { "${keycloak::install_base}/config.cli":
    ensure    => 'file',
    owner     => $keycloak::user,
    group     => $keycloak::group,
    mode      => '0600',
    content   => template('keycloak/config.cli.erb'),
    notify    => Exec['jboss-cli.sh --file=config.cli'],
    show_diff => false,
  }

  exec { 'jboss-cli.sh --file=config.cli':
    command     => "${keycloak::install_base}/bin/jboss-cli.sh --file=config.cli",
    cwd         => $keycloak::install_base,
    user        => $keycloak::user,
    group       => $keycloak::group,
    refreshonly => true,
    logoutput   => true,
    notify      => Class['keycloak::service'],
  }

  create_resources('keycloak::truststore::host', $keycloak::truststore_hosts)

}
