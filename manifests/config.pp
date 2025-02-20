# Private class.
class keycloak::config {
  assert_private()

  if $keycloak::install_base != '/opt/keycloak' {
    file { '/opt/keycloak':
      ensure => 'link',
      target => $keycloak::install_base,
    }
  }

  $wrapper_conf = {
    'KCADM'      => "${keycloak::install_base}/bin/kcadm.sh",
    'CONFIG'     => $keycloak::login_config,
    'SERVER'     => $keycloak::wrapper_server,
    'REALM'      => 'master',
    'ADMIN_USER' => $keycloak::admin_user,
    'PASSWORD'   => $keycloak::admin_user_password,
  }
  file { 'kcadm-wrapper.conf':
    ensure    => 'file',
    path      => $keycloak::wrapper_conf,
    owner     => 'root',
    group     => 'root',
    mode      => '0640',
    content   => epp('keycloak/shell_vars.epp', { 'vars' => $wrapper_conf }),
    show_diff => false,
  }

  file { 'kcadm-wrapper.sh':
    ensure    => 'file',
    path      => $keycloak::wrapper_path,
    owner     => 'root',
    group     => 'root',
    mode      => '0750',
    source    => 'puppet:///modules/keycloak/kcadm-wrapper.sh',
    show_diff => false,
    require   => File['kcadm-wrapper.conf'],
  }

  file { $keycloak::conf_dir:
    ensure  => 'directory',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    mode    => $keycloak::conf_dir_mode,
    purge   => $keycloak::conf_dir_purge,
    force   => $keycloak::conf_dir_purge,
    recurse => $keycloak::conf_dir_purge,
    ignore  => $keycloak::conf_dir_purge_ignore,
    notify  => Class['keycloak::service'],
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
  file { "${keycloak::conf_dir}/keycloak.conf":
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
