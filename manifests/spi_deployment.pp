# @summary Manage Keycloak SPI deployment
#
# @example
#   keycloak::spi_deployment { 'duo-spi':
#     ensure        => 'present',
#     deployed_name => 'keycloak-duo-spi-jar-with-dependencies.jar',
#     source        => 'file:///path/to/source/keycloak-duo-spi-jar-with-dependencies.jar',
#   }
#
# @param ensure
#   State of the deployment
# @param deployed_name
#   Name of the file to be deployed. Defaults to `$name`.
# @param source
#   Source of the deployment, supports 'file://', 'puppet://', 'https://' or 'http://'
#
define keycloak::spi_deployment (
  Variant[Stdlib::Filesource, Stdlib::HTTPSUrl] $source,
  Enum['present', 'absent'] $ensure = 'present',
  String[1] $deployed_name = $name,
) {
  include keycloak

  $dir = "${keycloak::install_base}/standalone/deployments"
  $basename = basename($source)
  $dest = "${dir}/${deployed_name}"
  $tmp = "${keycloak::install_base}/tmp/${basename}"
  $dodeploy = "${dest}.dodeploy"
  $deployed = "${dest}.deployed"

  if $ensure == 'present' {
    if $source =~ Stdlib::HTTPUrl or $source =~ Stdlib::HTTPSUrl {
      $_source = $tmp
      archive { $name:
        ensure  => 'present',
        extract => false,
        path    => $tmp,
        source  => $source,
        creates => $tmp,
        cleanup => false,
        user    => $keycloak::user,
        group   => $keycloak::group,
        require => File["${keycloak::install_base}/tmp"],
        before  => File[$dest],
      }
    } else {
      $_source = $source
    }
    file { $dest:
      ensure  => 'file',
      source  => $_source,
      owner   => $keycloak::user,
      group   => $keycloak::group,
      mode    => '0644',
      require => Class['keycloak::install'],
      notify  => Exec["${name}-dodeploy"],
    }
    exec { "${name}-dodeploy":
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      command     => "touch ${dodeploy}",
      refreshonly => true,
      user        => $keycloak::user,
      group       => $keycloak::group,
    }
  }

  if $ensure == 'absent' {
    file { $deployed:
      ensure => 'absent',
    }
  }

}
