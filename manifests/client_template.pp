# @summary Manage Keycloak client template
#
# @example
#   keycloak::client_template { 'oidc-clients':
#     realm => 'test',
#   }
#
# @param realm
#   Realm of the client template.
# @param resource_name
#   Name of the client template resource
# @param protocol
#   The protocol of the client template.
#
define keycloak::client_template (
  String $realm,
  String $resource_name = $name,
  Enum['openid-connect', 'saml'] $protocol = 'openid-connect',
) {

  warning('The keycloak::client_template defined type is deprecated. Use keycloak_client_scope and keycloak_protocol_mapper directly.')

  include ::keycloak

  keycloak_client_scope { $name:
    realm         => $realm,
    resource_name => $resource_name,
    protocol      => $protocol,
  }

  if $protocol == 'openid-connect' {
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

  if $protocol == 'saml' {
    keycloak_protocol_mapper { "username for ${name} on ${realm}":
      protocol             => $protocol,
      type                 => 'saml-user-property-mapper',
      attribute_nameformat => 'uri',
      user_attribute       => 'username',
      friendly_name        => 'userid',
      attribute_name       => 'urn:oid:0.9.2342.19200300.100.1.1'
    }

    keycloak_protocol_mapper { "X500 email for ${name} on ${realm}":
      protocol             => $protocol,
      type                 => 'saml-user-property-mapper',
      attribute_nameformat => 'uri',
      user_attribute       => 'email',
      friendly_name        => 'email',
      attribute_name       => 'urn:oid:1.2.840.113549.1.9.1'
    }

    keycloak_protocol_mapper { "X500 givenName for ${name} on ${realm}":
      protocol             => $protocol,
      type                 => 'saml-user-property-mapper',
      attribute_nameformat => 'uri',
      user_attribute       => 'firstName',
      friendly_name        => 'givenName',
      attribute_name       => 'urn:oid:2.5.4.42'
    }

    keycloak_protocol_mapper { "X500 surname for ${name} on ${realm}":
      protocol             => $protocol,
      type                 => 'saml-user-property-mapper',
      attribute_nameformat => 'uri',
      user_attribute       => 'lastName',
      friendly_name        => 'surname',
      attribute_name       => 'urn:oid:2.5.4.4'
    }

    keycloak_protocol_mapper { "role list for ${name} on ${realm}":
      protocol             => $protocol,
      type                 => 'saml-role-list-mapper',
      single               => false,
      attribute_nameformat => 'basic',
      attribute_name       => 'Role',
    }
  }

}
