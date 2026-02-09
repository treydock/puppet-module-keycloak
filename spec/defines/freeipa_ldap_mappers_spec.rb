# frozen_string_literal: true

require 'spec_helper'

describe 'keycloak::freeipa_ldap_mappers' do
  on_supported_os.each do |os, _facts|
    context "when #{os}" do
      let(:title) { 'ipa.example.org' }
      let(:params) do
        {
          realm: 'EXAMPLE.ORG',
          groups_dn: 'cn=groups,cn=accounts,dc=example,dc=org',
          roles_dn: 'cn=groups,cn=accounts,dc=example,dc=org',
          parent_id: 'ipa.example.org',
        }
      end

      it do
        is_expected.to contain_keycloak_ldap_mapper('groups for ipa.example.org').with(
          ensure: 'present',
          realm: 'EXAMPLE.ORG',
          type: 'group-ldap-mapper',
          ldap: 'ipa.example.org',
          is_mandatory_in_ldap: false,
          mode: 'READ_ONLY',
          memberof_ldap_attribute: 'memberOf',
          drop_non_existing_groups_during_sync: true,
          group_name_ldap_attribute: 'cn',
          group_object_classes: 'groupOfNames, posixGroup',
          groups_dn: 'cn=groups,cn=accounts,dc=example,dc=org',
          ignore_missing_groups: false,
          membership_attribute_type: 'DN',
          membership_ldap_attribute: 'member',
          membership_user_ldap_attribute: 'uid',
          preserve_group_inheritance: false,
          user_roles_retrieve_strategy: 'LOAD_GROUPS_BY_MEMBER_ATTRIBUTE',
        )
      end

      it do
        is_expected.to contain_keycloak_ldap_mapper('roles for ipa.example.org').with(
          ensure: 'present',
          realm: 'EXAMPLE.ORG',
          type: 'role-ldap-mapper',
          ldap: 'ipa.example.org',
          is_mandatory_in_ldap: false,
          mode: 'READ_ONLY',
          memberof_ldap_attribute: 'memberOf',
          membership_attribute_type: 'UID',
          membership_ldap_attribute: 'memberUid',
          membership_user_ldap_attribute: 'uid',
          role_name_ldap_attribute: 'cn',
          role_object_classes: 'posixGroup',
          roles_dn: 'cn=groups,cn=accounts,dc=example,dc=org',
          use_realm_roles_mapping: true,
          user_roles_retrieve_strategy: 'LOAD_ROLES_BY_MEMBER_ATTRIBUTE',
        )
      end

      it do
        attrs = [['cn', 'cn', 'cn'],
                 ['displayName', 'displayName', 'displayName'],
                 ['email', 'mail', 'email'],
                 ['first name', 'givenName', 'firstName'],
                 ['last name', 'sn', 'lastName'],
                 ['username', 'uid', 'username'],]

        attrs.each do |attr|
          name = attr[0]
          ldap_attribute = attr[1]
          user_model_attribute = attr[2]

          is_expected.to contain_keycloak_ldap_mapper("#{name} for ipa.example.org").with(
            ensure: 'present',
            realm: 'EXAMPLE.ORG',
            ldap: 'ipa.example.org',
            always_read_value_from_ldap: true,
            read_only: true,
            is_mandatory_in_ldap: true,
            ldap_attribute: ldap_attribute,
            user_model_attribute: user_model_attribute,
          )
        end
      end

      it do
        is_expected.to contain_keycloak_ldap_mapper('modify date for ipa.example.org').with(
          is_mandatory_in_ldap: false,
          ldap_attribute: 'modifyTimestamp',
          user_model_attribute: 'modifyTimestamp',
        )
      end

      it do
        is_expected.to contain_keycloak_ldap_mapper('creation date for ipa.example.org').with(
          is_mandatory_in_ldap: false,
          ldap_attribute: 'createTimestamp',
          user_model_attribute: 'createTimestamp',
        )
      end
    end
  end
end
