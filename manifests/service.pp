# Private class.
class keycloak::service {
  assert_private()

  if $::service_provider == 'systemd' {
    ::systemd::unit_file { 'keycloak.service':
      content => template('keycloak/keycloak.service.erb'),
      notify  => Service['keycloak'],
    }
    Exec['systemctl-daemon-reload'] -> Service['keycloak']
  }

  service { 'keycloak':
    ensure     => $keycloak::service_ensure,
    enable     => $keycloak::service_enable,
    name       => $keycloak::service_name,
    hasstatus  => $keycloak::service_hasstatus,
    hasrestart => $keycloak::service_hasrestart,
  }

}
