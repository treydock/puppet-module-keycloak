# @summary Add host to Keycloak truststore
#
# @example
#   keycloak::truststore::host { 'ldap1.example.com':
#     certificate => '/etc/openldap/certs/0a00000.0',
#   }
#
# @param certificate
#   Path to host certificate
# @param ensure
#   Host ensure value passed to `java_ks` resource.
#
define keycloak::truststore::host (
  String $certificate,
  Enum['latest', 'present', 'absent'] $ensure = 'latest',
) {

  include keycloak

  if $keycloak::operating_mode == 'domain' {
    $_path = "${keycloak::install_base}/domain/configuration/truststore.jks"
  } else {
    $_path = "${keycloak::install_base}/standalone/configuration/truststore.jks"
  }

  java_ks { $name:
    ensure       => $ensure,
    certificate  => $certificate,
    target       => $_path,
    password     => $keycloak::truststore_password,
    trustcacerts => true,
    notify       => Class['keycloak::service'],
  }

}
