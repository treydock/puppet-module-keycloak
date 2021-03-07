require 'spec_helper'

describe 'keycloak::freeipa_user_provider' do
  on_supported_os.each do |os, _facts|
    context "on #{os}" do
      let(:version) { '12.0.4' }
      let(:title) { 'ipa.example.org' }
      let(:params) do
        {
          realm: 'EXAMPLE.ORG',
          bind_dn: 'uid=ldapproxy,cn=sysaccounts,cn=etc,dc=example,dc=org',
          bind_credential: 'secret',
          users_dn: 'cn=users,cn=accounts,dc=example,dc=org',
          priority: 20,
        }
      end

      it do
        is_expected.to contain_keycloak_ldap_user_provider('ipa.example.org on EXAMPLE.ORG').with(
          ensure: 'present',
          auth_type: 'simple',
          bind_credential: 'secret',
          bind_dn: 'uid=ldapproxy,cn=sysaccounts,cn=etc,dc=example,dc=org',
          connection_url: 'ldap://ipa.example.org:389',
          edit_mode: 'READ_ONLY',
          import_enabled: 'true',
          priority: 20,
          rdn_ldap_attribute: 'uid',
          search_scope: '1',
          use_kerberos_for_password_authentication: 'false',
          use_truststore_spi: 'ldapsOnly',
          user_object_classes: ['inetOrgPerson', ' organizationalPerson'],
          username_ldap_attribute: 'uid',
          users_dn: 'cn=users,cn=accounts,dc=example,dc=org',
          uuid_ldap_attribute: 'ipaUniqueID',
          vendor: 'rhds',
        )
      end
    end
  end
end
