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

  file { "${keycloak::install_base}/tmp":
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0755',
  }

  $_add_user_keycloak_cmd = "${keycloak::install_base}/bin/add-user-keycloak.sh"
  $_add_user_keycloak_state = "${keycloak::install_base}/.create-keycloak-admin-${keycloak::datasource_driver}"

  if $::keycloak::operating_mode != 'domain' {
    $_server_conf_dir = "${keycloak::install_base}/standalone/configuration"
    $_add_user_keycloak_args = "--user ${keycloak::admin_user} --password ${keycloak::admin_user_password} --realm master"
    $_java_opts_path = "${keycloak::install_base}/bin/standalone.conf"

    $_dirs = [
      $_server_conf_dir
    ]
  } else {
    $_server_conf_dir = "${keycloak::install_base}/domain/servers/${keycloak::server_name}/configuration"
    $_add_user_keycloak_args = "--user ${keycloak::admin_user} --password ${keycloak::admin_user_password} --realm master --sc ${_server_conf_dir}/" # lint:ignore:140chars
    $_java_opts_path = "${keycloak::install_base}/bin/domain.conf"

    $_dirs = [
      "${keycloak::install_base}/domain/servers",
      "${keycloak::install_base}/domain/servers/${keycloak::server_name}",
      $_server_conf_dir
    ]

  }

  file { $_dirs:
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0755',
  }

  exec { 'create-keycloak-admin':
    command => "${_add_user_keycloak_cmd} ${_add_user_keycloak_args} && touch ${_add_user_keycloak_state}",
    creates => $_add_user_keycloak_state,
    notify  => Class['keycloak::service'],
    user    => $keycloak::user,
  }

  if $keycloak::operating_mode == 'domain' {
    $config_cli_prefix = '/profile=auth-server-clustered'
  } else {
    $config_cli_prefix = ''
  }

  concat { "${keycloak::install_base}/config.cli":
    owner          => $keycloak::user,
    group          => $keycloak::group,
    mode           => '0600',
    notify         => Exec['jboss-cli.sh --file=config.cli'],
    show_diff      => false,
    ensure_newline => true,
  }

  concat::fragment { 'keycloak-config.cli-header':
    target  => "${keycloak::install_base}/config.cli",
    content => epp('keycloak/config.cli/00-header.epp', {'operating_mode' => $keycloak::operating_mode}),
    order   => '00',
  }

  if $keycloak::proxy_https {
    concat::fragment { 'keycloak-config.cli-https-proxy':
      target  => "${keycloak::install_base}/config.cli",
      content => epp('keycloak/config.cli/01-https-proxy.epp', {
        'prefix'         => $config_cli_prefix,
        'operating_mode' => $keycloak::operating_mode,
      }),
      order   => '01',
    }
  }

  concat::fragment { 'keycloak-config.cli-datasource':
    target  => "${keycloak::install_base}/config.cli",
    content => epp('keycloak/config.cli/02-datasource.epp', {
      'datasource_driver'         => $keycloak::datasource_driver,
      'datasource_connection_url' => $keycloak::datasource_connection_url,
      'datasource_username'       => $keycloak::datasource_username,
      'datasource_password'       => $keycloak::datasource_password,
      'mysql_datasource_class'    => $keycloak::mysql_datasource_class,
      'prefix'                    => $config_cli_prefix,
    }),
    order   => '02',
  }

  concat::fragment { 'keycloak-config.cli-truststore':
    target  => "${keycloak::install_base}/config.cli",
    content => epp('keycloak/config.cli/03-truststore.epp', {
      'truststore'                              => $keycloak::truststore,
      'operating_mode'                          => $keycloak::operating_mode,
      'install_base'                            => $keycloak::install_base,
      'truststore_password'                     => $keycloak::truststore_password,
      'truststore_hostname_verification_policy' => $keycloak::truststore_hostname_verification_policy,
      'prefix'                                  => $config_cli_prefix,
    }),
    order   => '03',
  }

  concat::fragment { 'keycloak-config.cli-theming':
    target  => "${keycloak::install_base}/config.cli",
    content => epp('keycloak/config.cli/04-theming.epp', {
      'theme_static_max_age'  => $keycloak::theme_static_max_age,
      'theme_cache_themes'    => $keycloak::theme_cache_themes,
      'theme_cache_templates' => $keycloak::theme_cache_templates,
      'prefix'                => $config_cli_prefix,
    }),
    order   => '04',
  }

  # deployment scanner is not compatible with domain mode
  if $keycloak::operating_mode != 'domain' {
    concat::fragment { 'keycloak-config.cli-deployment-scanner':
      target  => "${keycloak::install_base}/config.cli",
      content => epp('keycloak/config.cli/05-deployment-scanner.epp', {
        'auto_deploy_exploded' => $keycloak::auto_deploy_exploded,
        'auto_deploy_zipped'   => $keycloak::auto_deploy_zipped,
        'prefix'               => $config_cli_prefix,
      }),
      order   => '05',
    }
  }

  concat::fragment { 'keycloak-config.cli-user-cache':
    target  => "${keycloak::install_base}/config.cli",
    content => epp('keycloak/config.cli/06-user-cache.epp', {
      'user_cache' => $keycloak::user_cache,
      'prefix'     => $config_cli_prefix,
    }),
    order   => '06',
  }

  concat::fragment { 'keycloak-config.cli-cluster':
    target  => "${keycloak::install_base}/config.cli",
    content => epp('keycloak/config.cli/10-cluster.epp', {
      'operating_mode'             => $keycloak::operating_mode,
      'enable_jdbc_ping'           => $keycloak::enable_jdbc_ping,
      'datasource_driver'          => $keycloak::datasource_driver,
      'jboss_bind_private_address' => $keycloak::jboss_bind_private_address,
      'jboss_bind_public_address'  => $keycloak::jboss_bind_public_address,
      'prefix'                     => $config_cli_prefix,
    }),
    order   => '10',
  }

  if $keycloak::operating_mode == 'domain' {
    concat::fragment { 'keycloak-config.cli-domain':
      target  => "${keycloak::install_base}/config.cli",
      content => epp('keycloak/config.cli/11-domain.epp', {
        'prefix' => $config_cli_prefix,
      }),
      order   => '11',
    }
  }

  concat::fragment { 'keycloak-config.cli-syslog':
    target  => "${keycloak::install_base}/config.cli",
    content => epp('keycloak/config.cli/12-syslog.epp', {
      'prefix'                => $config_cli_prefix,
      'syslog'                => $keycloak::syslog,
      'syslog_app_name'       => $keycloak::syslog_app_name,
      'syslog_facility'       => $keycloak::syslog_facility,
      'syslog_hostname'       => $keycloak::syslog_hostname,
      'syslog_level'          => $keycloak::syslog_level,
      'syslog_port'           => $keycloak::syslog_port,
      'syslog_server_address' => $keycloak::syslog_server_address,
      'syslog_format'         => $keycloak::syslog_format,
    }),
      order => '12',
  }

  if $keycloak::custom_config_content or $keycloak::custom_config_source {
    concat::fragment { 'keycloak-config.cli-custom':
      target  => "${keycloak::install_base}/config.cli",
      content => $keycloak::custom_config_content,
      source  => $keycloak::custom_config_source,
      order   => '50',
    }
  }

  concat::fragment { 'keycloak-config.cli-footer':
    target  => "${keycloak::install_base}/config.cli",
    content => epp('keycloak/config.cli/99-footer.epp', {'operating_mode' => $keycloak::operating_mode}),
    order   => '99',
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
  file_line { 'keycloak-JAVA_OPTS':
    ensure => $java_opts_ensure,
    path   => $_java_opts_path,
    line   => "JAVA_OPTS=\"${_java_opts}\"",
    match  => '^JAVA_OPTS=',
    notify => Class['keycloak::service'],
  }

  file { "${_server_conf_dir}/profile.properties":
    ensure  => 'file',
    owner   => $keycloak::user,
    group   => $keycloak::group,
    content => template('keycloak/profile.properties.erb'),
    mode    => '0644',
    notify  => Class['keycloak::service'],
  }

  if $::keycloak::operating_mode == 'domain' {
    $_add_user_wildfly_cmd = "${keycloak::install_base}/bin/add-user.sh"
    $_add_user_wildfly_args = "--user ${keycloak::wildfly_user} --password ${keycloak::wildfly_user_password} -e -s"
    $_add_user_wildfly_state = "${::keycloak::install_base}/.create-wildfly-user"

    exec { 'create-wildfly-user':
      command => "${_add_user_wildfly_cmd} ${_add_user_wildfly_args} && touch ${_add_user_wildfly_state}",
      creates => $_add_user_wildfly_state,
      notify  => Class['keycloak::service'],
    }

    if $keycloak::role == 'master' {
      # Remove load balancer group
      # Rename the server
      # Set port offset to zero to run server on port 8080
      augeas { 'ensure-servername':
        incl      => "${keycloak::install_base}/domain/configuration/host-master.xml",
        context   => "/files${keycloak::install_base}/domain/configuration/host-master.xml/host/servers",
        load_path => '/opt/puppetlabs/puppet/share/augeas/lenses/dist',
        lens      => 'Xml.lns',
        changes   => [
          'rm server[1]',
          'rm server',
          "set server/#attribute/name ${keycloak::server_name}",
          'set server/#attribute/group auth-server-group',
          'set server/#attribute/auto-start true',
          'set server/socket-bindings/#attribute/port-offset 0',
        ],
        notify    => Class['keycloak::service'],
      }

      # Set up interface names and defaults in host-master.xml
      augeas { 'ensure-interface-names-defaults-master':
        incl      => "${keycloak::install_base}/domain/configuration/host-master.xml",
        context   => "/files${keycloak::install_base}/domain/configuration/host-master.xml/host/interfaces",
        load_path => '/opt/puppetlabs/puppet/share/augeas/lenses/dist',
        lens      => 'Xml.lns',
        changes   => [
          # lint:ignore:single_quote_string_with_variables
          'set interface[1]/#attribute/name management',
          'set interface[1]/inet-address/#attribute/value ${jboss.bind.address.management:127.0.0.1}',
          'set interface[2]/#attribute/name private',
          'set interface[2]/inet-address/#attribute/value ${jboss.bind.address.private:127.0.0.1}',
          'set interface[3]/#attribute/name public',
          'set interface[3]/inet-address/#attribute/value ${jboss.bind.address:127.0.0.1}',
          # lint:endignore
        ],
        notify    => Class['keycloak::service'],
      }

      # Assing management interfaces to logical interfaces
      augeas { 'assign-management-interfaces-master':
        incl      => "${keycloak::install_base}/domain/configuration/host-master.xml",
        context   => "/files${keycloak::install_base}/domain/configuration/host-master.xml/host/management/management-interfaces",
        load_path => '/opt/puppetlabs/puppet/share/augeas/lenses/dist',
        lens      => 'Xml.lns',
        changes   => [
          # lint:ignore:single_quote_string_with_variables
          'set native-interface/#attribute/security-realm ManagementRealm',
          'set native-interface/socket/#attribute/interface management',
          'set native-interface/socket/#attribute/port ${jboss.management.native.port:9999}',
          'set http-interface/#attribute/security-realm ManagementRealm',
          'set http-interface/socket/#attribute/interface management',
          'set http-interface/socket/#attribute/port ${jboss.management.http.port:9990}',
          # lint:endignore
        ],
        notify    => Class['keycloak::service'],
      }
    } else {
      # Rename the server
      # Set port offset to zero, to run server in port 8080
      augeas { 'ensure-servername':
        incl      => "${keycloak::install_base}/domain/configuration/host-slave.xml",
        context   => "/files${keycloak::install_base}/domain/configuration/host-slave.xml/host/servers",
        load_path => '/opt/puppetlabs/puppet/share/augeas/lenses/dist',
        lens      => 'Xml.lns',
        changes   => [
          "set server/#attribute/name ${keycloak::server_name}",
          'set server/socket-bindings/#attribute/port-offset 0'
        ],
        notify    => Class['keycloak::service'],
      }

      # Set username for authentication to master
      augeas { 'ensure-username':
        incl      => "${keycloak::install_base}/domain/configuration/host-slave.xml",
        context   => "/files${keycloak::install_base}/domain/configuration/host-slave.xml/host/domain-controller/remote",
        load_path => '/opt/puppetlabs/puppet/share/augeas/lenses/dist',
        lens      => 'Xml.lns',
        changes   => [
          "set #attribute/username ${keycloak::wildfly_user}"
        ],
        notify    => Class['keycloak::service'],
      }

      # Set secret for authentication to master
      augeas { 'ensure-secret':
        incl      => "${keycloak::install_base}/domain/configuration/host-slave.xml",
        context   => "/files${keycloak::install_base}/domain/configuration/host-slave.xml/host/management/security-realms/security-realm[1]/server-identities/secret", # lint:ignore:140chars
        load_path => '/opt/puppetlabs/puppet/share/augeas/lenses/dist',
        lens      => 'Xml.lns',
        changes   => [
          "set #attribute/value ${keycloak::wildfly_user_password_base64}"
        ],
        notify    => Class['keycloak::service'],
      }

      # Set up interface names and default in host-slave.xml
      augeas { 'ensure-interface-names-defaults-slave':
        incl      => "${keycloak::install_base}/domain/configuration/host-slave.xml",
        context   => "/files${keycloak::install_base}/domain/configuration/host-slave.xml/host/interfaces",
        load_path => '/opt/puppetlabs/puppet/share/augeas/lenses/dist',
        lens      => 'Xml.lns',
        changes   => [
          # lint:ignore:single_quote_string_with_variables
          'set interface[1]/#attribute/name management',
          'set interface[1]/inet-address/#attribute/value ${jboss.bind.address.management:127.0.0.1}',
          'set interface[2]/#attribute/name private',
          'set interface[2]/inet-address/#attribute/value ${jboss.bind.address.private:127.0.0.1}',
          'set interface[3]/#attribute/name public',
          'set interface[3]/inet-address/#attribute/value ${jboss.bind.address:127.0.0.1}',
          # lint:endignore
        ],
        notify    => Class['keycloak::service'],
      }

      # Assing management interfaces to logical interfaces
      augeas { 'assign-management-interaces-slave':
        incl      => "${keycloak::install_base}/domain/configuration/host-slave.xml",
        context   => "/files${keycloak::install_base}/domain/configuration/host-slave.xml/host/management/management-interfaces",
        load_path => '/opt/puppetlabs/puppet/share/augeas/lenses/dist',
        lens      => 'Xml.lns',
        changes   => [
          # lint:ignore:single_quote_string_with_variables
          'set native-interface/#attribute/security-realm ManagementRealm',
          'set native-interface/socket/#attribute/interface management',
          'set native-interface/socket/#attribute/port ${jboss.management.native.port:9999}',
          'set http-interface/#attribute/security-realm ManagementRealm',
          'set http-interface/socket/#attribute/interface management',
          'set http-interface/socket/#attribute/port ${jboss.management.http.port:9990}',
          # lint:endignore
        ],
        notify    => Class['keycloak::service'],
      }
    }
  }
}
