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

  $_add_user_keycloak_cmd = "${keycloak::install_base}/bin/add-user-keycloak.sh"
  $_add_user_keycloak_args = "--user ${keycloak::admin_user} --password ${keycloak::admin_user_password} --realm master"
  $_add_user_keycloak_state = "${keycloak::install_base}/.create-keycloak-admin-${keycloak::datasource_driver}"
  exec { 'create-keycloak-admin':
    command => "${_add_user_keycloak_cmd} ${_add_user_keycloak_args} && touch ${_add_user_keycloak_state}",
    creates => $_add_user_keycloak_state,
    notify  => Class['keycloak::service'],
  }

  file { "${keycloak::install_base}/tmp":
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0755',
  }

  file { "${keycloak::install_base}/standalone/configuration":
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0750',
  }

  file { "${keycloak::install_base}/standalone/configuration/profile.properties":
    ensure  => 'file',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    content => template('keycloak/profile.properties.erb'),
    mode    => '0644',
    notify  => Class['keycloak::service'],
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

  if $keycloak::java_opts {
    $java_opts_ensure = 'present'
  } else {
    $java_opts_ensure = 'absent'
  }

  if $keycloak::java_opts =~ Array {
    $java_opts = join($keycloak::java_opts, ' ')
  } else {
    $java_opts = $keycloak::java_opts
  }
  if $keycloak::java_opts_append {
    $_java_opts = "\$JAVA_OPTS ${java_opts}"
  } else {
    $_java_opts = $java_opts
  }
  file_line { 'standalone.conf-JAVA_OPTS':
    ensure => $java_opts_ensure,
    path   => "${keycloak::install_base}/bin/standalone.conf",
    line   => "JAVA_OPTS=\"${_java_opts}\"",
    match  => '^JAVA_OPTS=',
    notify => Class['keycloak::service'],
  }
}
