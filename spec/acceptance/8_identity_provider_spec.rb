require 'spec_helper_acceptance'

describe 'keycloak_identity_provider type:', if: RSpec.configuration.keycloak_full do
  context 'creates identity provider' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_identity_provider { 'cilogon on test':
        ensure                         => 'present',
        display_name                   => 'CILogon',
        provider_id                    => 'oidc',
        first_broker_login_flow_alias  => 'browser',
        client_id                      => 'cilogon:/client_id/foobar',
        client_secret                  => 'supersecret',
        user_info_url                  => 'https://cilogon.org/oauth2/userinfo',
        token_url                      => 'https://cilogon.org/oauth2/token',
        authorization_url              => 'https://cilogon.org/authorize',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created identity provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get identity-provider/instances/cilogon -r test' do
        data = JSON.parse(stdout)
        expect(data['enabled']).to eq(true)
        expect(data['displayName']).to eq('CILogon')
      end
    end
  end

  context 'updates identity provider' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_identity_provider { 'cilogon on test':
        ensure                         => 'present',
        display_name                   => 'CILogon',
        provider_id                    => 'oidc',
        first_broker_login_flow_alias  => 'first broker login',
        client_id                      => 'cilogon:/client_id/foobar',
        client_secret                  => 'supersecret',
        user_info_url                  => 'https://cilogon.org/oauth2/userinfo',
        token_url                      => 'https://cilogon.org/oauth2/token',
        authorization_url              => 'https://cilogon.org/authorize',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created identity provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get identity-provider/instances/cilogon -r test' do
        data = JSON.parse(stdout)
        expect(data['enabled']).to eq(true)
        expect(data['firstBrokerLoginFlowAlias']).to eq('first broker login')
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
      keycloak_identity_provider { 'cilogon on test':
        ensure => 'absent',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has deleted identity provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get identity-provider/instances -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['alias'] == 'cilogon' }[0]
        expect(d).to be_nil
      end
    end
  end
end
