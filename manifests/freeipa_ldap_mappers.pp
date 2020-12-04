#
# @summary setup FreeIPA LDAP mappers for Keycloak
#
# @example
#   keycloak::freeipa_ldap_mappers { 'ipa.example.org':
#     ldap_provider_id => '6bd0f68d-5618-a74d-bcab-089702f1bc80',
#     realm            => 'EXAMPLE.ORG',
#     groups_dn        => 'cn=groups,cn=accounts,dc=example,dc=org',
#     roles_dn         => 'cn=groups,cn=accounts,dc=example,dc=org'
#   }
#
# @param parent_name
#   The name of the parent resource. Usually the title of the
#   keycloak_ldap_provider.
# @param realm
#   Keycloak realm
# @param groups_dn
#   Groups DN
# @param roles_dn
#   Roles DN
# @param ldap_provider_id
#   Identifier for the LDAP provider to add this mapper to
#
define keycloak::freeipa_ldap_mappers
(
  String $realm,
  String $groups_dn,
  String $roles_dn,
  String $parent_name = $title,
  String $ldap_provider_id = $title,
)
{
  $title_suffix = "for ${ldap_provider_id} on ${realm}"

  # This translates to parentId in JSON and must be correct or hard-to-debug
  # issues will ensue.
  $ldap = "${parent_name}-${realm}"

  keycloak_ldap_mapper {
    default:
      ensure                      => 'present',
      ldap                        => $ldap,
      always_read_value_from_ldap => true,
      read_only                   => true,
      is_mandatory_in_ldap        => true,
    ;
    ["cn ${title_suffix}"]:
      ldap_attribute       => 'cn',
      user_model_attribute => 'cn',
    ;
    ["displayName ${title_suffix}"]:
      ldap_attribute       => 'displayName',
      user_model_attribute => 'displayName',
    ;
    ["email ${title_suffix}"]:
      ldap_attribute       => 'mail',
      user_model_attribute => 'email',
    ;
    ["first name ${title_suffix}"]:
      ldap_attribute       => 'givenName',
      user_model_attribute => 'firstName',
    ;
    ["last name ${title_suffix}"]:
      ldap_attribute       => 'sn',
      user_model_attribute => 'lastName',
    ;
    ["username ${title_suffix}"]:
      ldap_attribute       => 'uid',
      user_model_attribute => 'username',
    ;
    ["modify date ${title_suffix}"]:
      is_mandatory_in_ldap => false,
      ldap_attribute       => 'modifyTimestamp',
      user_model_attribute => 'modifyTimestamp',
    ;
    ["creation date ${title_suffix}"]:
      is_mandatory_in_ldap => false,
      ldap_attribute       => 'createTimestamp',
      user_model_attribute => 'createTimestamp',
    ;
  }

  keycloak_ldap_mapper { "roles ${title_suffix}":
    ensure                         => 'present',
    type                           => 'role-ldap-mapper',
    ldap                           => $ldap,
    is_mandatory_in_ldap           => false,
    mode                           => 'READ_ONLY',
    memberof_ldap_attribute        => 'memberOf',
    membership_attribute_type      => 'UID',
    membership_ldap_attribute      => 'memberUid',
    membership_user_ldap_attribute => 'uid',
    read_only                      => true,
    role_name_ldap_attribute       => 'cn',
    role_object_classes            => 'posixGroup',
    roles_dn                       => $roles_dn,
    use_realm_roles_mapping        => true,
    user_roles_retrieve_strategy   => 'LOAD_ROLES_BY_MEMBER_ATTRIBUTE',
  }

  keycloak_ldap_mapper { "groups ${title_suffix}":
    ensure                               => 'present',
    type                                 => 'group-ldap-mapper',
    ldap                                 => $ldap,
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
    read_only                            => true,
    user_roles_retrieve_strategy         => 'LOAD_GROUPS_BY_MEMBER_ATTRIBUTE',
  }
}
