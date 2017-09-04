require 'spec_helper_acceptance'

describe 'keycloak_ldap_user_provider:' do
  context 'creates ldap' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'test':
        realm => 'test',
        users_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
      }
      keycloak_ldap_mapper { 'full-name':
        realm => 'test',
        ldap  => 'test-test',
        type => 'full-name-ldap-mapper',
        ldap_attribute => 'foo',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  context 'updates ldap' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'test':
        realm => 'test',
        users_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
        user_object_classes => ['posixAccount'],
      }
      keycloak_ldap_mapper { 'full-name':
        realm => 'test',
        ldap  => 'test-test',
        type => 'full-name-ldap-mapper',
        ldap_attribute => 'bar',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
