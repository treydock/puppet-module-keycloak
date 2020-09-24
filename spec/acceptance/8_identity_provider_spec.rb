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
        jwks_url                       => 'https://cilogon.org/jwks',
        gui_order                      => 1,
      }
      keycloak_identity_provider { 'foo on test':
        ensure                         => 'present',
        display_name                   => 'foo',
        provider_id                    => 'keycloak-oidc',
        first_broker_login_flow_alias  => 'browser',
        client_id                      => 'foobar',
        client_secret                  => 'supersecret',
        user_info_url                  => 'https://foo/oauth2/userinfo',
        token_url                      => 'https://foo/oauth2/token',
        authorization_url              => 'https://foo/authorize',
        gui_order                      => 2,
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
        expect(data['providerId']).to eq('oidc')
        expect(data['config']['jwksUrl']).to eq('https://cilogon.org/jwks')
        expect(data['config']['guiOrder']).to eq('1')
        expect(data['config']['syncMode']).to eq('IMPORT')
      end
    end

    it 'has created keycloak-oidc identity provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get identity-provider/instances/foo -r test' do
        data = JSON.parse(stdout)
        expect(data['enabled']).to eq(true)
        expect(data['displayName']).to eq('foo')
        expect(data['providerId']).to eq('keycloak-oidc')
        expect(data['config']['userInfoUrl']).to eq('https://foo/oauth2/userinfo')
        expect(data['config']['tokenUrl']).to eq('https://foo/oauth2/token')
        expect(data['config']['authorizationUrl']).to eq('https://foo/authorize')
        expect(data['config']['guiOrder']).to eq('2')
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
        jwks_url                       => 'https://cilogon.org/jwks',
        gui_order                      => 3,
        sync_mode                      => 'FORCE',
      }
      keycloak_identity_provider { 'foo on test':
        ensure                         => 'present',
        display_name                   => 'foo',
        provider_id                    => 'keycloak-oidc',
        first_broker_login_flow_alias  => 'browser',
        client_id                      => 'foobar',
        client_secret                  => 'supersecret',
        user_info_url                  => 'https://foo/userinfo',
        token_url                      => 'https://foo/token',
        authorization_url              => 'https://foo/authorize',
        gui_order                      => 4,
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
        expect(data['providerId']).to eq('oidc')
        expect(data['config']['jwksUrl']).to eq('https://cilogon.org/jwks')
        expect(data['firstBrokerLoginFlowAlias']).to eq('first broker login')
        expect(data['config']['guiOrder']).to eq('3')
        expect(data['config']['syncMode']).to eq('FORCE')
      end
    end

    it 'has created keycloak-oidc identity provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get identity-provider/instances/foo -r test' do
        data = JSON.parse(stdout)
        expect(data['enabled']).to eq(true)
        expect(data['displayName']).to eq('foo')
        expect(data['providerId']).to eq('keycloak-oidc')
        expect(data['config']['userInfoUrl']).to eq('https://foo/userinfo')
        expect(data['config']['tokenUrl']).to eq('https://foo/token')
        expect(data['config']['authorizationUrl']).to eq('https://foo/authorize')
        expect(data['config']['guiOrder']).to eq('4')
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
