require 'spec_helper_acceptance'

describe 'flow types:', if: RSpec.configuration.keycloak_full do
  context 'creates flow' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_flow { 'browser-with-duo on test':
        ensure => 'present',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a flow' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/flows/browser-with-duo-test -r test' do
        data = JSON.parse(stdout)
        expect(data['alias']).to eq('browser-with-duo')
        expect(data['topLevel']).to eq(true)
      end
    end
  end

  context 'updates flow' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_flow { 'browser-with-duo on test':
        ensure => 'present',
        description => 'browser with Duo',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a flow' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/flows/browser-with-duo-test -r test' do
        data = JSON.parse(stdout)
        expect(data['description']).to eq('browser with Duo')
      end
    end
  end

  context 'ensure => absent' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_flow { 'browser-with-duo on test':
        ensure => 'absent',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has deleted a flow' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/flows -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['alias'] == 'browser-with-duo' }[0]
        expect(d).to be_nil
      end
    end
  end
end
