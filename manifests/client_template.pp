#
define keycloak::client_template (
  String $realm,
  String $resource_name = $name,
  Enum['openid-connect'] $protocol = 'openid-connect',
  Boolean $full_scope_allowed = true,
) {

  include ::keycloak

  keycloak_client_template { $name:
    realm              => $realm,
    resource_name      => $resource_name,
    protocol           => $protocol,
    full_scope_allowed => $full_scope_allowed,
  }

  keycloak_protocol_mapper { "email for ${name} on ${realm}":
    consent_text   => '${email}', #lint:ignore:single_quote_string_with_variables
    claim_name     => 'email',
    user_attribute => 'email',
  }

  keycloak_protocol_mapper { "username for ${name} on ${realm}":
    consent_text   => '${username}', #lint:ignore:single_quote_string_with_variables
    claim_name     => 'preferred_username',
    user_attribute => 'username',
  }

  keycloak_protocol_mapper { "full name for ${name} on ${realm}":
    consent_text         => '${fullName}', #lint:ignore:single_quote_string_with_variables
    type                 => 'oidc-full-name-mapper',
    userinfo_token_claim => false,
  }

  keycloak_protocol_mapper { "family name for ${name} on ${realm}":
    consent_text   => '${familyName}', #lint:ignore:single_quote_string_with_variables
    claim_name     => 'family_name',
    user_attribute => 'lastName',
  }

  keycloak_protocol_mapper { "given name for ${name} on ${realm}":
    consent_text   => '${givenName}', #lint:ignore:single_quote_string_with_variables
    claim_name     => 'given_name',
    user_attribute => 'firstName',
  }

}
