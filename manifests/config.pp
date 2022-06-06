# Private class.
class keycloak::config {
  assert_private()

  if $keycloak::install_base != '/opt/keycloak' {
    file { '/opt/keycloak':
      ensure => 'link',
      target => $keycloak::install_base,
    }
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

  file { $keycloak::admin_env:
    ensure    => 'file',
    owner     => $keycloak::user,
    group     => $keycloak::group,
    mode      => '0600',
    content   => join([
      '# File managed by Puppet',
      "KEYCLOAK_ADMIN=${keycloak::admin_user}",
      "KEYCLOAK_ADMIN_PASSWORD=${keycloak::admin_user_password}",
      '',
    ], "\n"),
    show_diff => false,
  }

  if $keycloak::custom_config_content {
    $config_content = $keycloak::custom_config_content
  } else {
    $config_content = template('keycloak/keycloak.conf.erb')
  }
  file { "${keycloak::install_base}/conf/keycloak.conf":
    owner     => $keycloak::user,
    group     => $keycloak::group,
    mode      => '0600',
    show_diff => false,
    content   => $config_content,
    source    => $keycloak::custom_config_source,
    notify    => Class['keycloak::service'],
  }

  create_resources('keycloak::truststore::host', $keycloak::truststore_hosts)

  file { $keycloak::tmp_dir:
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0755',
  }

  file { $keycloak::providers_dir:
    ensure  => 'directory',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => '0755',
    purge   => $keycloak::providers_purge,
    force   => $keycloak::providers_purge,
    recurse => $keycloak::providers_purge,
    notify  => Class['keycloak::service'],
  }
}
