# Private class.
class keycloak::config {
  assert_private()

  file { '/opt/keycloak':
    ensure => 'link',
    target => $keycloak::install_base,
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

  file { "${keycloak::install_base}/tmp":
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0755',
  }

  if $::keycloak::operating_mode == 'domain' {
    contain ::keycloak::config::domain
  }
  else {
    contain ::keycloak::config::standalone
  }
}
