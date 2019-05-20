# Private class.
class keycloak::params {

  $libunix_dbus_java_source = 'https://github.com/keycloak/libunix-dbus-java/archive/libunix-dbus-java-0.8.0.tar.gz'

  case $::osfamily {
    'Debian': {
      $service_name       = 'keycloak'
      $service_hasstatus  = true
      $service_hasrestart = true
      $user_shell         = '/usr/sbin/nologin'
      $libunix_dbus_java_build_dependencies = [
        'zlib1g-dev',
        'libtool',
        'automake',
        'autoconf',
        'make',
      ]
      $libunix_dbus_java_libdir = '/usr/lib'
      $jna_package_name = 'libjna-java'
      $default_postgresql_jar_source = '/usr/share/java/postgresql.jar'
    }
    'RedHat': {
      $service_name       = 'keycloak'
      $service_hasstatus  = true
      $service_hasrestart = true
      $user_shell         = '/sbin/nologin'
      $libunix_dbus_java_build_dependencies = [
        'which',
        'zlib-devel',
        'libtool',
        'automake',
        'autoconf',
        'make',
      ]
      $libunix_dbus_java_libdir = '/usr/lib64'
      $jna_package_name = 'jna'
      $default_postgresql_jar_source = '/usr/share/java/postgresql-jdbc.jar'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamilies Debian and Redhat")
    }
  }

}
