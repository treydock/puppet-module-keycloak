#
define keycloak::truststore::host (
  String $certificate,
  Enum['latest', 'present', 'absent'] $ensure = 'latest',
) {

  include keycloak

  java_ks { $name:
    ensure       => $ensure,
    certificate  => $certificate,
    target       => "${keycloak::install_base}/standalone/configuration/truststore.jks",
    password     => $keycloak::truststore_password,
    trustcacerts => true,
    notify       => Class['keycloak::service'],
  }

}
