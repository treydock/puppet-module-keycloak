#
# @summary setup IPA as an LDAP user provider for Keycloak
#
# @example Add FreeIPA as a user provider
#   keycloak::freeipa_user_provider { 'ipa.example.org':
#     ensure          => 'present',
#     realm           => 'EXAMPLE.ORG',
#     bind_dn         => 'uid=ldapproxy,cn=sysaccounts,cn=etc,dc=example,dc=org',
#     bind_credential => 'secret',
#     users_dn        => 'cn=users,cn=accounts,dc=example,dc=org',
#     priority        => 10,
#   }
#
# @param ensure
#   LDAP user provider status
# @param id
#    ID to use for user provider
# @param ipa_host
#   Hostname of the FreeIPA server (e.g. ipa.example.org)
# @param realm
#   Keycloak realm
# @param bind_dn
#   LDAP bind dn
# @param bind_credential
#   LDAP bind password
# @param users_dn
#   The DN for user search
# @param priority
#   Priority for this user provider
# @param ldaps
#   Use LDAPS protocol instead of LDAP
# @param full_sync_period
#   Synchronize all users this often (fullSyncPeriod)
# @param changed_sync_period
#   Synchronize changed users this often (changedSyncPeriod)
#
define keycloak::freeipa_user_provider
(
  String                    $realm,
  String                    $bind_dn,
  String                    $bind_credential,
  String                    $users_dn,
  Enum['present', 'absent'] $ensure = 'present',
  Optional[String]          $id = undef,
  Stdlib::Host              $ipa_host = $title,
  Integer                   $priority = 10,
  Boolean                   $ldaps = false,
  Optional[Integer]         $full_sync_period = undef,
  Optional[Integer]         $changed_sync_period = undef
)
{
  if $ldaps {
    $connection_url = "ldaps://${ipa_host}:636"
  }
  else {
    $connection_url = "ldap://${ipa_host}:389"
  }

  keycloak_ldap_user_provider { "${ipa_host} on ${realm}":
    ensure                                   => 'present',
    id                                       => $id,
    auth_type                                => 'simple',
    bind_credential                          => $bind_credential,
    bind_dn                                  => $bind_dn,
    connection_url                           => $connection_url,
    edit_mode                                => 'READ_ONLY',
    import_enabled                           => 'true',
    priority                                 => $priority,
    rdn_ldap_attribute                       => 'uid',
    search_scope                             => '1',
    use_kerberos_for_password_authentication => 'false',
    use_truststore_spi                       => 'ldapsOnly',
    user_object_classes                      => ['inetOrgPerson', ' organizationalPerson'],
    username_ldap_attribute                  => 'uid',
    users_dn                                 => $users_dn,
    uuid_ldap_attribute                      => 'ipaUniqueID',
    vendor                                   => 'rhds',
    full_sync_period                         => $full_sync_period,
    changed_sync_period                      => $changed_sync_period,
  }
}
