require 'spec_helper_acceptance'

describe 'keycloak::user_federation::ldap define:' do
  context 'creates ldap' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak::realm { 'test': }->
      keycloak::user_federation::ldap { 'test':
        realm => 'test',
        user_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
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
      keycloak::realm { 'test': }->
      keycloak::user_federation::ldap { 'test':
        realm => 'test',
        user_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
        user_objectclasses => ['posixAccount'],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
