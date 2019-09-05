require 'spec_helper_acceptance'

describe 'keycloak_api:', if: RSpec.configuration.keycloak_full do
  context 'bootstraps' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
  context 'creates realm' do
    it 'runs successfully' do
      pp = <<-EOS
      keycloak_api { 'keycloak':
        install_base => '/opt/keycloak',
      }
      keycloak_realm { 'test2': ensure => 'present' }
      EOS

      on hosts, 'rm -f /opt/keycloak/bin/kcadm-wrapper.sh'
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a realm' do
      on hosts, '/opt/keycloak/bin/kcadm.sh get realms/test2 --no-config --server http://localhost:8080/auth --realm master --user admin --password changeme' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('test2')
      end
    end
  end

  context 'updates realm' do
    it 'runs successfully' do
      pp = <<-EOS
      keycloak_api { 'keycloak':
        install_base => '/opt/keycloak',
      }
      keycloak_realm { 'test2':
        ensure => 'present',
        remember_me => true,
      }
      EOS

      on hosts, 'rm -f /opt/keycloak/bin/kcadm-wrapper.sh'
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a realm' do
      on hosts, '/opt/keycloak/bin/kcadm.sh get realms/test2 --no-config --server http://localhost:8080/auth --realm master --user admin --password changeme' do
        data = JSON.parse(stdout)
        expect(data['rememberMe']).to eq(true)
      end
    end
  end
end
