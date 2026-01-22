# @summary Manage Keycloak SAML client scope using built-in mappers
#
# @example
#   keycloak::client_scope::saml { 'saml-clients':
#     realm => 'test',
#   }
#
# @param realm
#   Realm of the client scope.
# @param resource_name
#   Name of the client scope resource
#
define keycloak::client_scope::saml (
  String $realm,
  String $resource_name = $name,
) {
  include keycloak

  keycloak_client_scope { $name:
    realm         => $realm,
    resource_name => $resource_name,
    protocol      => 'saml',
  }

  keycloak_protocol_mapper { "username for ${name} on ${realm}":
    protocol             => 'saml',
    type                 => 'saml-user-property-mapper',
    attribute_nameformat => 'uri',
    user_attribute       => 'username',
    friendly_name        => 'userid',
    attribute_name       => 'urn:oid:0.9.2342.19200300.100.1.1',
  }

  keycloak_protocol_mapper { "X500 email for ${name} on ${realm}":
    protocol             => 'saml',
    type                 => 'saml-user-property-mapper',
    attribute_nameformat => 'uri',
    user_attribute       => 'email',
    friendly_name        => 'email',
    attribute_name       => 'urn:oid:1.2.840.113549.1.9.1',
  }

  keycloak_protocol_mapper { "X500 givenName for ${name} on ${realm}":
    protocol             => 'saml',
    type                 => 'saml-user-property-mapper',
    attribute_nameformat => 'uri',
    user_attribute       => 'firstName',
    friendly_name        => 'givenName',
    attribute_name       => 'urn:oid:2.5.4.42',
  }

  keycloak_protocol_mapper { "X500 surname for ${name} on ${realm}":
    protocol             => 'saml',
    type                 => 'saml-user-property-mapper',
    attribute_nameformat => 'uri',
    user_attribute       => 'lastName',
    friendly_name        => 'surname',
    attribute_name       => 'urn:oid:2.5.4.4',
  }

  keycloak_protocol_mapper { "role list for ${name} on ${realm}":
    protocol             => 'saml',
    type                 => 'saml-role-list-mapper',
    single               => false,
    attribute_nameformat => 'basic',
    attribute_name       => 'Role',
  }
}
