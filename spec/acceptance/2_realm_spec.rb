require 'spec_helper_acceptance'

describe 'keycloak_realm:' do
  context 'creates realm' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have created a realm' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('test')
      end
    end

    it 'should have left default-client-scopes' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test/default-default-client-scopes' do
        data = JSON.parse(stdout)
        names = data.map { |d| d['name'] }.sort
        expect(names).to eq(['email', 'profile', 'role_list'])
      end
    end

    it 'should have left optional-client-scopes' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test/default-optional-client-scopes' do
        data = JSON.parse(stdout)
        names = data.map { |d| d['name'] }.sort
        expect(names).to eq(['address', 'offline_access', 'phone'])
      end
    end
  end

  context 'updates realm' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test':
        ensure => 'present',
        remember_me => true,
        default_client_scopes => ['profile'],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have updated the realm' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test' do
        data = JSON.parse(stdout)
        expect(data['rememberMe']).to eq(true)
      end
    end

    it 'should have updated the realm default-client-scopes' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test/default-default-client-scopes' do
        data = JSON.parse(stdout)
        names = data.map { |d| d['name'] }
        expect(names).to eq(['profile'])
      end
    end
  end
end
