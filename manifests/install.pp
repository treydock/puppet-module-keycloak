# Private class.
class keycloak::install {
  assert_private()

  user { 'keycloak':
    ensure     => 'present',
    name       => $keycloak::user,
    forcelocal => true,
    shell      => $keycloak::user_shell,
    gid        => $keycloak::group,
    uid        => $keycloak::user_uid,
    home       => '/var/lib/keycloak',
    managehome => true,
  }

  group { 'keycloak':
    ensure     => 'present',
    name       => $keycloak::group,
    forcelocal => true,
    gid        => $keycloak::group_gid,
  }

  file { "${keycloak::install_dir}/keycloak-${keycloak::version}":
    ensure => 'directory',
    owner  => $keycloak::user,
    group  => $keycloak::group,
    mode   => '0755',
  }
  -> archive { "keycloak-${keycloak::version}.tar.gz":
    ensure          => 'present',
    extract         => true,
    path            => "/tmp/keycloak-${keycloak::version}.tar.gz",
    extract_path    => "${keycloak::install_dir}/keycloak-${keycloak::version}",
    extract_command => 'tar xfz %s --strip-components=1',
    source          => $keycloak::download_url,
    creates         => "${keycloak::install_dir}/keycloak-${keycloak::version}/bin",
    cleanup         => true,
    user            => 'keycloak',
    group           => 'keycloak',
  }

}
