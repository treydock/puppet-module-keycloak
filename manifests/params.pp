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
    'RedHat': {
      $service_name       = 'keycloak'
      $service_hasstatus  = true
      $service_hasrestart = true
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
