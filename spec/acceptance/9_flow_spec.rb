require 'spec_helper_acceptance'

describe 'flow types:', if: RSpec.configuration.keycloak_full do
  context 'creates flow' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak::spi_deployment { 'duo-spi':
        deployed_name => 'keycloak-duo-spi-jar-with-dependencies.jar',
        source        => 'file:///tmp/keycloak-duo-spi-jar-with-dependencies.jar',
        test_url      => 'authentication/authenticator-providers',
        test_key      => 'id',
        test_value    => 'duo-mfa-authenticator',
        test_realm    => 'test',
        test_before   => [
          'Keycloak_flow[form-browser-with-duo]',
          'Keycloak_flow_execution[duo-mfa-authenticator under form-browser-with-duo on test]',
        ],
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_flow { 'browser-with-duo on test':
        ensure => 'present',
      }
      keycloak_flow_execution { 'duo-mfa-authenticator under form-browser-with-duo on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Duo MFA',
        alias        => 'Duo',
        config       => {
          "duomfa.akey"    => "foo-akey",
          "duomfa.apihost" => "api-foo.duosecurity.com",
          "duomfa.skey"    => "secret",
          "duomfa.ikey"    => "foo-ikey",
          "duomfa.groups"  => "duo"
        },
        requirement  => 'REQUIRED',
        index        => 1,
      }
      keycloak_flow_execution { 'duo-mfa-authenticator under form-browser-with-duo2 on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Duo MFA',
        alias        => 'Duo2',
        requirement  => 'REQUIRED',
        index        => 0,
      }
      keycloak_flow_execution { 'auth-username-password-form under form-browser-with-duo on test':
        ensure       => 'present',
        configurable => false,
        display_name => 'Username Password Form',
        index        => 0,
        requirement  => 'REQUIRED',
      }
      keycloak_flow { 'form-browser-with-duo under browser-with-duo on test':
        ensure      => 'present',
        index       => 2,
        requirement => 'ALTERNATIVE',
        top_level   => false,
      }
      keycloak_flow { 'form-browser-with-duo2 under browser-with-duo on test':
        ensure      => 'present',
        index       => 3,
        requirement => 'REQUIRED',
        top_level   => false,
      }
      keycloak_flow_execution { 'auth-cookie under browser-with-duo on test':
        ensure       => 'present',
        configurable => false,
        display_name => 'Cookie',
        index        => 0,
        requirement  => 'ALTERNATIVE',
      }
      keycloak_flow_execution { 'identity-provider-redirector under browser-with-duo on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Identity Provider Redirector',
        index        => 1,
        requirement  => 'ALTERNATIVE',
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

    it 'has executions' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/flows/browser-with-duo/executions -r test' do
        data = JSON.parse(stdout)
        cookie = data.find { |d| d['providerId'] == 'auth-cookie' }
        expect(cookie['index']).to eq(0)
        idp = data.find { |d| d['providerId'] == 'identity-provider-redirector' }
        expect(idp['index']).to eq(1)
        form = data.find { |d| d['displayName'] == 'form-browser-with-duo' }
        expect(form['index']).to eq(2)
        auth_form = data.find { |d| d['providerId'] == 'auth-username-password-form' }
        expect(auth_form['index']).to eq(0)
        duo = data.find { |d| d['providerId'] == 'duo-mfa-authenticator' }
        expect(duo['index']).to eq(1)
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
      keycloak::spi_deployment { 'duo-spi':
        deployed_name => 'keycloak-duo-spi-jar-with-dependencies.jar',
        source        => 'file:///tmp/keycloak-duo-spi-jar-with-dependencies.jar',
        test_url      => 'authentication/authenticator-providers',
        test_key      => 'id',
        test_value    => 'duo-mfa-authenticator',
        test_realm    => 'test',
        test_before   => [
          'Keycloak_flow[form-browser-with-duo]',
          'Keycloak_flow_execution[duo-mfa-authenticator under form-browser-with-duo on test]',
        ],
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_flow { 'browser-with-duo on test':
        ensure => 'present',
        description => 'browser with Duo',
      }
      keycloak_flow_execution { 'duo-mfa-authenticator under form-browser-with-duo on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Duo MFA',
        alias        => 'Duo',
        config       => {
          "duomfa.akey"    => "foo-akey2",
          "duomfa.apihost" => "api-foo.duosecurity.com",
          "duomfa.skey"    => "secret2",
          "duomfa.ikey"    => "foo-ikey2",
          "duomfa.groups"  => "duo,duo2"
        },
        requirement  => 'REQUIRED',
        index        => 0,
      }
      keycloak_flow_execution { 'duo-mfa-authenticator under form-browser-with-duo2 on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Duo MFA',
        alias        => 'Duo2',
        config       => {
          "duomfa.akey"    => "foo-akey2",
          "duomfa.apihost" => "api-foo.duosecurity.com",
          "duomfa.skey"    => "secret2",
          "duomfa.ikey"    => "foo-ikey2",
          "duomfa.groups"  => "duo,duo2"
        },
        requirement  => 'REQUIRED',
        index        => 0,
      }
      keycloak_flow_execution { 'auth-username-password-form under form-browser-with-duo on test':
        ensure       => 'present',
        configurable => false,
        display_name => 'Username Password Form',
        index        => 1,
        requirement  => 'REQUIRED',
      }
      keycloak_flow { 'form-browser-with-duo under browser-with-duo on test':
        ensure      => 'present',
        index       => 2,
        requirement => 'REQUIRED',
        top_level   => false,
      }
      keycloak_flow { 'form-browser-with-duo2 under browser-with-duo on test':
        ensure      => 'present',
        index       => 3,
        requirement => 'REQUIRED',
        top_level   => false,
      }
      keycloak_flow_execution { 'auth-cookie under browser-with-duo on test':
        ensure       => 'present',
        configurable => false,
        display_name => 'Cookie',
        index        => 1,
        requirement  => 'ALTERNATIVE',
      }
      keycloak_flow_execution { 'identity-provider-redirector under browser-with-duo on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Identity Provider Redirector',
        index        => 0,
        requirement  => 'ALTERNATIVE',
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

    it 'has executions' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/flows/browser-with-duo/executions -r test' do
        data = JSON.parse(stdout)
        cookie = data.find { |d| d['providerId'] == 'auth-cookie' }
        expect(cookie['index']).to eq(1)
        idp = data.find { |d| d['providerId'] == 'identity-provider-redirector' }
        expect(idp['index']).to eq(0)
        form = data.find { |d| d['displayName'] == 'form-browser-with-duo' }
        expect(form['index']).to eq(2)
        auth_form = data.find { |d| d['providerId'] == 'auth-username-password-form' }
        expect(auth_form['index']).to eq(1)
        duo = data.find { |d| d['providerId'] == 'duo-mfa-authenticator' }
        expect(duo['index']).to eq(0)
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
      keycloak_flow_execution { 'auth-cookie under browser-with-duo on test':
        ensure => 'absent',
      }
      keycloak_flow_execution { 'identity-provider-redirector under browser-with-duo on test':
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
