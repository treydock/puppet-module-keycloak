#
# @summary setup FreeIPA LDAP mappers for Keycloak
#
# @example
#   keycloak::freeipa_ldap_mappers { 'ipa.example.org':
#     realm            => 'EXAMPLE.ORG',
#     groups_dn        => 'cn=groups,cn=accounts,dc=example,dc=org',
#     roles_dn         => 'cn=groups,cn=accounts,dc=example,dc=org'
#   }
#
# @param realm
#   Keycloak realm
# @param groups_dn
#   Groups DN
# @param roles_dn
#   Roles DN
# @param parent_id
#   Used to identify the parent LDAP user provider, name used with keycloak::freeipa_user_provider
#
define keycloak::freeipa_ldap_mappers (
  String $realm,
  String $groups_dn,
  String $roles_dn,
  String $parent_id = $title,
) {
  $title_suffix = "for ${title}"
  $defaults = {
    ensure                      => 'present',
    realm                       => $realm,
    ldap                        => $parent_id,
    always_read_value_from_ldap => true,
    read_only                   => true,
  }

  keycloak_ldap_mapper { "cn ${title_suffix}":
    *                    => $defaults,
    ldap_attribute       => 'cn',
    user_model_attribute => 'cn',
    is_mandatory_in_ldap => true,
  }

  keycloak_ldap_mapper { "displayName ${title_suffix}":
    *                    => $defaults,
    ldap_attribute       => 'displayName',
    user_model_attribute => 'displayName',
    is_mandatory_in_ldap => true,
  }

  keycloak_ldap_mapper { "email ${title_suffix}":
    *                    => $defaults,
    ldap_attribute       => 'mail',
    user_model_attribute => 'email',
    is_mandatory_in_ldap => true,
  }

  keycloak_ldap_mapper { "first name ${title_suffix}":
    *                    => $defaults,
    ldap_attribute       => 'givenName',
    user_model_attribute => 'firstName',
    is_mandatory_in_ldap => true,
  }

  keycloak_ldap_mapper { "last name ${title_suffix}":
    *                    => $defaults,
    ldap_attribute       => 'sn',
    user_model_attribute => 'lastName',
    is_mandatory_in_ldap => true,
  }

  keycloak_ldap_mapper { "username ${title_suffix}":
    *                    => $defaults,
    ldap_attribute       => 'uid',
    user_model_attribute => 'username',
    is_mandatory_in_ldap => true,
  }

  keycloak_ldap_mapper { "modify date ${title_suffix}":
    *                    => $defaults,
    ldap_attribute       => 'modifyTimestamp',
    user_model_attribute => 'modifyTimestamp',
    is_mandatory_in_ldap => false,
  }

  keycloak_ldap_mapper { "creation date ${title_suffix}":
    *                    => $defaults,
    ldap_attribute       => 'createTimestamp',
    user_model_attribute => 'createTimestamp',
    is_mandatory_in_ldap => false,
  }

  keycloak_ldap_mapper { "roles ${title_suffix}":
    ensure                         => 'present',
    realm                          => $realm,
    type                           => 'role-ldap-mapper',
    ldap                           => $parent_id,
    is_mandatory_in_ldap           => false,
    mode                           => 'READ_ONLY',
    memberof_ldap_attribute        => 'memberOf',
    membership_attribute_type      => 'UID',
    membership_ldap_attribute      => 'memberUid',
    membership_user_ldap_attribute => 'uid',
    role_name_ldap_attribute       => 'cn',
    role_object_classes            => 'posixGroup',
    roles_dn                       => $roles_dn,
    use_realm_roles_mapping        => true,
    user_roles_retrieve_strategy   => 'LOAD_ROLES_BY_MEMBER_ATTRIBUTE',
  }

  keycloak_ldap_mapper { "groups ${title_suffix}":
    ensure                               => 'present',
    realm                                => $realm,
    type                                 => 'group-ldap-mapper',
    ldap                                 => $parent_id,
    is_mandatory_in_ldap                 => false,
    mode                                 => 'READ_ONLY',
    memberof_ldap_attribute              => 'memberOf',
    drop_non_existing_groups_during_sync => true,
    group_name_ldap_attribute            => 'cn',
    group_object_classes                 => 'groupOfNames, posixGroup',
    groups_dn                            => $groups_dn,
    ignore_missing_groups                => false,
    membership_attribute_type            => 'DN',
    membership_ldap_attribute            => 'member',
    membership_user_ldap_attribute       => 'uid',
    preserve_group_inheritance           => false,
    user_roles_retrieve_strategy         => 'LOAD_GROUPS_BY_MEMBER_ATTRIBUTE',
  }
}
