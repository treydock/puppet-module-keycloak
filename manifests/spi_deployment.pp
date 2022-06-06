# @summary Manage Keycloak SPI deployment
#
# @example Add Duo SPI
#   keycloak::spi_deployment { 'duo-spi':
#     ensure        => 'present',
#     deployed_name => 'keycloak-duo-spi-jar-with-dependencies.jar',
#     source        => 'file:///path/to/source/keycloak-duo-spi-jar-with-dependencies.jar',
#   }
#
# @example Add Duo SPI and check API for existance of resources before going onto dependenct resources
#   keycloak::spi_deployment { 'duo-spi':
#     deployed_name => 'keycloak-duo-spi-jar-with-dependencies.jar',
#     source        => 'file:///path/to/source/keycloak-duo-spi-jar-with-dependencies.jar',
#     test_url      => 'authentication/authenticator-providers',
#     test_key      => 'id',
#     test_value    => 'duo-mfa-authenticator',
#     test_realm    => 'test',
#     before        => Keycloak_flow_execution['duo-mfa-authenticator under form-browser-with-duo on test'],
#  }
#
# @param ensure
#   State of the deployment
# @param deployed_name
#   Name of the file to be deployed. Defaults to `$name`.
# @param source
#   Source of the deployment, supports 'file://', 'puppet://', 'https://' or 'http://'
# @param test_url
#   URL to test for existance of resources created by this SPI
# @param test_key
#   Key of resource when testing for resource created by this SPI
# @param test_value
#   Value of the `test_key` when testing for resources created by this SPI
# @param test_realm
#   Realm to query when looking for resources created by this SPI
# @param test_before
#   Setup autorequires for validator dependent resources
#
define keycloak::spi_deployment (
  Variant[Stdlib::Filesource, Stdlib::HTTPSUrl] $source,
  Enum['present', 'absent'] $ensure = 'present',
  String[1] $deployed_name = $name,
  Optional[String] $test_url = undef,
  Optional[String] $test_key = undef,
  Optional[String] $test_value = undef,
  Optional[String] $test_realm = undef,
  Optional[Array] $test_before = undef,
) {
  include keycloak

  $basename = basename($source)
  $dest = "${keycloak::providers_dir}/${deployed_name}"
  $tmp = "${keycloak::tmp_dir}/${basename}"

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
        require => File[$keycloak::tmp_dir],
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
      notify  => Class['keycloak::service'],
    }

    if $test_url and $test_key and $test_value {
      keycloak_resource_validator { $name:
        test_url            => $test_url,
        test_key            => $test_key,
        test_value          => $test_value,
        realm               => $test_realm,
        dependent_resources => $test_before,
        require             => Class['keycloak::service'],
      }
    }
  }

  if $ensure == 'absent' {
    file { $dest:
      ensure => 'absent',
    }
  }

}
