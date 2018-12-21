# Private class.
class keycloak::sssd {
  assert_private()

  if $facts['java_default_home'] {
    $jvm_path = $facts['java_default_home']
  } else {
    $jvm_path = '$(dirname $(dirname $(readlink -f $(which javac))))'
  }

  if $keycloak::install_libunix_dbus_java_build_dependencies {
    $build_dependency_defaults = {
      'ensure' => 'installed',
      'before' => Exec['libunix-dbus-java-setup'],
    }
    ensure_packages($keycloak::libunix_dbus_java_build_dependencies, $build_dependency_defaults)
  }

  file { '/usr/local/src/libunix-dbus-java':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  -> archive { 'libunix-dbus-java.tar.gz':
    ensure          => 'present',
    extract         => true,
    path            => '/tmp/libunix-dbus-java.tar.gz',
    extract_path    => '/usr/local/src/libunix-dbus-java',
    extract_command => 'tar xfz %s --strip-components=1',
    source          => $keycloak::libunix_dbus_java_source,
    creates         => '/usr/local/src/libunix-dbus-java/src',
    cleanup         => true,
    user            => 'root',
    group           => 'root',
    before          => Exec['libunix-dbus-java-setup'],
  }

  exec { 'libunix-dbus-java-setup':
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    cwd     => '/usr/local/src/libunix-dbus-java',
    command => 'libtoolize && aclocal && autoconf && automake --add-missing',
    creates => '/usr/local/src/libunix-dbus-java/configure',
  }
  -> exec { 'libunix-dbus-java-configure':
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    cwd     => '/usr/local/src/libunix-dbus-java',
    command => "/usr/local/src/libunix-dbus-java/configure --with-jvm=${jvm_path} --libdir=${keycloak::libunix_dbus_java_libdir} CFLAGS='-std=c99'",
    creates => '/usr/local/src/libunix-dbus-java/Makefile',
  }
  -> exec { 'libunix-dbus-java-make':
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    cwd     => '/usr/local/src/libunix-dbus-java',
    command => 'make',
    creates => '/usr/local/src/libunix-dbus-java/.libs/libunix_dbus_java.so.0.0.8',
  }
  -> exec { 'libunix-dbus-java-make-install':
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    cwd     => '/usr/local/src/libunix-dbus-java',
    command => 'make install',
    creates => "${keycloak::libunix_dbus_java_libdir}/libunix_dbus_java.so.0.0.8",
  }

  package { 'jna':
    ensure => 'installed',
    name   => $keycloak::jna_package_name,
  }

}
