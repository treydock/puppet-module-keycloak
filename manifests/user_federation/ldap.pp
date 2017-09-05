#
define keycloak::user_federation::ldap (
  String $realm,
  String $user_dn,
  String $connection_url,
  String $resource_name = $name,
  Integer $priority = 0,
  Boolean $import_enabled = true,
  Array $user_objectclasses = ['inetOrgPerson', 'organizationalPerson'],
  String $username_ldap_attribute = 'uid',
  String $rdn_ldap_attribute = 'uid',
  String $uuid_ldap_attribute = 'entryUUID',
  Enum['none', 'simple'] $auth_type = 'none',
  Enum['READ_ONLY', 'WRITABLE', 'UNSYNCED'] $edit_mode = 'READ_ONLY',
  Enum['ad', 'rhds', 'tivoli', 'eDirectory', 'other'] $vendor = 'other',
  String $use_truststore_spi = 'ldapsOnly',
) {

  warning('Keycloak::User_federation::Ldap is deprecated, use keycloak_ldap_user_provider type directly')

  include ::keycloak

  keycloak_ldap_user_provider { $name:
    realm                   => $realm,
    users_dn                => $user_dn,
    connection_url          => $connection_url,
    resource_name           => $resource_name,
    priority                => $priority,
    import_enabled          => $import_enabled,
    user_object_classes     => $user_objectclasses,
    username_ldap_attribute => $username_ldap_attribute,
    rdn_ldap_attribute      => $rdn_ldap_attribute,
    uuid_ldap_attribute     => $uuid_ldap_attribute,
    auth_type               => $auth_type,
    edit_mode               => $edit_mode,
    vendor                  => $vendor,
    use_truststore_spi      => $use_truststore_spi,
  }

}
