# Private class.
class keycloak::install {
  assert_private()

  if $keycloak::manage_user {
    user { 'keycloak':
      ensure     => 'present',
      name       => $keycloak::user,
      forcelocal => true,
      shell      => $keycloak::user_shell,
      gid        => $keycloak::group,
      uid        => $keycloak::user_uid,
      home       => '/var/lib/keycloak',
      managehome => true,
      system     => $keycloak::system_user,
    }
    group { 'keycloak':
      ensure     => 'present',
      name       => $keycloak::group,
      forcelocal => true,
      gid        => $keycloak::group_gid,
      system     => $keycloak::system_user,
    }
  }

  if $keycloak::manage_install {
    file { $keycloak::install_base:
      ensure => 'directory',
      owner  => $keycloak::user,
      group  => $keycloak::group,
      mode   => '0755',
    }
    -> archive { "keycloak-${keycloak::version}.tar.gz":
      ensure          => 'present',
      extract         => true,
      path            => "/tmp/keycloak-${keycloak::version}.tar.gz",
      extract_path    => $keycloak::install_base,
      extract_command => 'tar xfz %s --strip-components=1',
      source          => $keycloak::download_url,
      creates         => "${keycloak::install_base}/bin",
      cleanup         => true,
      user            => $keycloak::user,
      group           => $keycloak::group,
    }
  } else {
    # Set permissions properly when using a package
    exec { 'ensure-keycloak-dir-owner':
      command => "chown -R ${keycloak::user}:${keycloak::group} ${keycloak::install_base}",
      unless  => "test `stat -c %U ${keycloak::install_base}` = ${keycloak::user}",
      path    => ['/bin','/usr/bin'],
    }
  }
}
