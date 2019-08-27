# @summary Manage Keycloak OpenID Connect client scope using built-in mappers
#
# @example
#   keycloak::client_scope::oidc { 'oidc-clients':
#     realm => 'test',
#   }
#
# @param realm
#   Realm of the client scope.
# @param resource_name
#   Name of the client scope resource
#
define keycloak::client_scope::oidc (
  String $realm,
  String $resource_name = $name,
) {

  include ::keycloak

  keycloak_client_scope { $name:
    realm         => $realm,
    resource_name => $resource_name,
    protocol      => 'openid-connect',
  }

  keycloak_protocol_mapper { "email for ${name} on ${realm}":
    claim_name     => 'email',
    user_attribute => 'email',
  }

  keycloak_protocol_mapper { "username for ${name} on ${realm}":
    claim_name     => 'preferred_username',
    user_attribute => 'username',
  }

  keycloak_protocol_mapper { "full name for ${name} on ${realm}":
    type                 => 'oidc-full-name-mapper',
    userinfo_token_claim => false,
  }

  keycloak_protocol_mapper { "family name for ${name} on ${realm}":
    claim_name     => 'family_name',
    user_attribute => 'lastName',
  }

  keycloak_protocol_mapper { "given name for ${name} on ${realm}":
    claim_name     => 'given_name',
    user_attribute => 'firstName',
  }

}
