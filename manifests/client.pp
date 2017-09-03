#
define keycloak::client (
  String $realm,
  Array $redirect_uris,
  String $client_template,
  Optional[String] $secret,
) {

  warning('Keycloak::Client is deprecated, use keycloak_client type directly')

  include ::keycloak

  keycloak_client { $name:
    realm           => $realm,
    redirect_uris   => $redirect_uris,
    client_template => $client_template,
    secret          => $secret,
  }

}
