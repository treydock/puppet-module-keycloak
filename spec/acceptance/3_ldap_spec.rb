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
      keycloak_ldap_user_provider { 'LDAP':
        realm => 'test',
        users_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
      }
      keycloak_ldap_mapper { 'full-name':
        realm => 'test',
        ldap  => 'LDAP-test',
        type => 'full-name-ldap-mapper',
        ldap_attribute => 'foo',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have created a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components/LDAP-test -r test' do
        data = JSON.parse(stdout)
        expect(data['config']['usersDn']).to eq(['ou=People,dc=test'])
        expect(data['config']['connectionUrl']).to eq(['ldap://localhost:389'])
      end
    end

    it 'should have created a LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'full-name' }[0]
        expect(d['providerId']).to eq('full-name-ldap-mapper')
        expect(d['config']['ldap.full.name.attribute']).to eq(['foo'])
      end
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
      keycloak_ldap_user_provider { 'LDAP':
        realm => 'test',
        users_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
        user_object_classes => ['posixAccount'],
      }
      keycloak_ldap_mapper { 'full-name':
        realm => 'test',
        ldap  => 'LDAP-test',
        type => 'full-name-ldap-mapper',
        ldap_attribute => 'bar',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have updated a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components/LDAP-test -r test' do
        data = JSON.parse(stdout)
        expect(data['config']['usersDn']).to eq(['ou=People,dc=test'])
        expect(data['config']['connectionUrl']).to eq(['ldap://localhost:389'])
        expect(data['config']['userObjectClasses']).to eq(['posixAccount'])
      end
    end

    it 'should have updated a LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'full-name' }[0]
        expect(d['providerId']).to eq('full-name-ldap-mapper')
        expect(d['config']['ldap.full.name.attribute']).to eq(['bar'])
      end
    end
  end
end
