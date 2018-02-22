# Private class.
class keycloak::params {

  $service_java_opts  = [
    '-server',
    '-Xms64m',
    '-Xmx512m',
    '-XX:MetaspaceSize=96M',
    '-XX:MaxMetaspaceSize=256m',
    '-Djava.net.preferIPv4Stack=true',
    '-Djboss.modules.system.pkgs=org.jboss.byteman',
    '-Djava.awt.headless=true',
  ]

  case $::osfamily {
    'Debian': {
      $service_name       = 'keycloak'
      $service_hasstatus  = true
      $service_hasrestart = true
      $user_shell         = '/usr/sbin/nologin'
    }
    'RedHat': {
      $service_name       = 'keycloak'
      $service_hasstatus  = true
      $service_hasrestart = true
      $user_shell         = '/sbin/nologin'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamilies Debian and Redhat")
    }
  }

}
