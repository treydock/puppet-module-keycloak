#
define keycloak::user_federation::ldap_mapper (
  String $realm,
  String $ldap,
  String $ldap_attribute,
  String $resource_name = $name,
  Enum['user-attribute-ldap-mapper', 'full-name-ldap-mapper'] $type = 'user-attribute-ldap-mapper',
  Boolean $is_mandatory_in_ldap = false,
  Boolean $read_only = true,
  Boolean $write_only = false,
  Optional[String] $model_attribute = undef,
  ) {

  warning('Keycloak::User_federation::Ldap_mapper is deprecated, use keycloak_ldap_mapper type directly')

  include ::keycloak

  keycloak_ldap_mapper { $name:
    realm                => $realm,
    ldap                 => $ldap,
    ldap_attribute       => $ldap_attribute,
    resource_name        => $resource_name,
    type                 => $type,
    is_mandatory_in_ldap => $is_mandatory_in_ldap,
    read_only            => $read_only,
    write_only           => $write_only,
    user_model_attribute => $model_attribute,
  }

}
