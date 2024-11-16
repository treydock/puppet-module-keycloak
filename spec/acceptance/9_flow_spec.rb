# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'flow types:', if: RSpec.configuration.keycloak_full do
  context 'when creates flow' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak::spi_deployment { 'duo-spi':
        deployed_name => 'DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar',
        source        => 'file:///tmp/DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar',
        test_url      => 'authentication/authenticator-providers',
        test_key      => 'id',
        test_value    => 'duo-universal',
        test_realm    => 'test',
        test_before   => [
          'Keycloak_flow[form-browser-with-duo]',
          'Keycloak_flow_execution[duo-universal under form-browser-with-duo on test]',
        ],
      }
      keycloak::spi_deployment { 'osc-keycloak-scripts':
        deployed_name => 'osc-keycloak-scripts-jar-with-dependencies.jar',
        source        => "https://github.com/OSC/osc-keycloak-scripts/releases/download/1.1.0/osc-keycloak-scripts-1.1.0-jar-with-dependencies.jar",
        test_url      => 'authentication/authenticator-providers',
        test_key      => 'id',
        test_value    => 'script-user-enabled-authenticator.js',
        test_realm    => 'test',
        test_before   => [
          'Keycloak_flow[form-browser-with-duo]',
          'Keycloak_flow_execution[script-user-enabled-authenticator.js under form-browser-with-duo on test]',
        ],
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_flow { 'browser-with-duo on test':
        ensure      => 'present',
        description => 'Browser with DUO',
      }
      keycloak_flow_execution { 'auth-cookie under browser-with-duo on test':
        ensure       => 'present',
        configurable => false,
        display_name => 'Cookie',
        priority     => 10,
        requirement  => 'ALTERNATIVE',
      }
      keycloak_flow_execution { 'identity-provider-redirector under browser-with-duo on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Identity Provider Redirector',
        priority     => 20,
        requirement  => 'ALTERNATIVE',
      }
      keycloak_flow { 'form-browser-with-duo under browser-with-duo on test':
        ensure      => 'present',
        priority    => 30,
        requirement => 'ALTERNATIVE',
        top_level   => false,
        description => 'Form Browser with DUO',
      }
      keycloak_flow_execution { 'auth-username-password-form under form-browser-with-duo on test':
        ensure       => 'present',
        configurable => false,
        display_name => 'Username Password Form',
        priority     => 10,
        requirement  => 'REQUIRED',
      }
      keycloak_flow_execution { 'script-user-enabled-authenticator.js under form-browser-with-duo on test':
        ensure      => 'present',
        requirement => 'REQUIRED',
        priority    => 15,
      }
      keycloak_flow_execution { 'duo-universal under form-browser-with-duo on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Duo Universal MFA',
        alias        => 'Duo Universal',
        config       => {
          "duoApiHostname"    => "api-foo.duosecurity.com",
          "duoSecretKey"      => "secret",
          "duoIntegrationKey" => "foo-ikey",
          "duoGroups"         => "duo"
        },
        requirement  => 'REQUIRED',
        priority     => 20,
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a flow' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/flows/browser-with-duo-test -r test' do
        data = JSON.parse(stdout)
        expect(data['alias']).to eq('browser-with-duo')
        expect(data['description']).to eq('Browser with DUO')
        expect(data['topLevel']).to eq(true)
      end
    end

    it 'has executions' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/flows/browser-with-duo/executions -r test' do
        data = JSON.parse(stdout)
        form = data.find { |d| d['displayName'] == 'form-browser-with-duo' }
        expect(form['index']).to eq(2)
        cookie = data.find { |d| d['providerId'] == 'auth-cookie' }
        expect(cookie['index']).to eq(0)
        idp = data.find { |d| d['providerId'] == 'identity-provider-redirector' }
        expect(idp['index']).to eq(1)
        expect(form['description']).to eq('Form Browser with DUO')
        auth_form = data.find { |d| d['providerId'] == 'auth-username-password-form' }
        expect(auth_form['index']).to eq(0)
        script = data.find { |d| d['authenticationConfig'] == 'script-user-enabled-authenticator.js' }
        expect(script['index']).to eq(1)
        duo = data.find { |d| d['providerId'] == 'duo-universal' }
        expect(duo['index']).to eq(2)
      end
    end
  end

  context 'when updates flow' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak::spi_deployment { 'duo-spi':
        deployed_name => 'DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar',
        source        => 'file:///tmp/DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar',
        test_url      => 'authentication/authenticator-providers',
        test_key      => 'id',
        test_value    => 'duo-universal',
        test_realm    => 'test',
        test_before   => [
          'Keycloak_flow[form-browser-with-duo]',
          'Keycloak_flow_execution[duo-universal under form-browser-with-duo on test]',
        ],
      }
      keycloak::spi_deployment { 'osc-keycloak-scripts':
        deployed_name => 'osc-keycloak-scripts-jar-with-dependencies.jar',
        source        => "https://github.com/OSC/osc-keycloak-scripts/releases/download/1.1.0/osc-keycloak-scripts-1.1.0-jar-with-dependencies.jar",
        test_url      => 'authentication/authenticator-providers',
        test_key      => 'id',
        test_value    => 'script-user-enabled-authenticator.js',
        test_realm    => 'test',
        test_before   => [
          'Keycloak_flow[form-browser-with-duo]',
          'Keycloak_flow_execution[script-user-enabled-authenticator.js under form-browser-with-duo on test]',
        ],
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_flow { 'browser-with-duo on test':
        ensure => 'present',
        description => 'browser with Duo',
      }
      keycloak_flow_execution { 'auth-cookie under browser-with-duo on test':
        ensure       => 'present',
        configurable => false,
        display_name => 'Cookie',
        priority     => 25,
        requirement  => 'ALTERNATIVE',
      }
      keycloak_flow_execution { 'identity-provider-redirector under browser-with-duo on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Identity Provider Redirector',
        priority     => 15,
        requirement  => 'ALTERNATIVE',
      }
      keycloak_flow { 'form-browser-with-duo under browser-with-duo on test':
        ensure      => 'present',
        priority    => 30,
        requirement => 'REQUIRED',
        top_level   => false,
      }
      keycloak_flow_execution { 'duo-universal under form-browser-with-duo on test':
        ensure       => 'present',
        configurable => true,
        display_name => 'Duo Universal MFA',
        alias        => 'Duo Universal',
        config       => {
          "duoApiHostname"    => "api-foo.duosecurity.com",
          "duoSecretKey"      => "secret2",
          "duoIntegrationKey" => "foo-ikey2",
          "duoGroups"         => "duo"
        },
        requirement  => 'REQUIRED',
        priority     => 15,
      }
      keycloak_flow_execution { 'auth-username-password-form under form-browser-with-duo on test':
        ensure       => 'present',
        configurable => false,
        display_name => 'Username Password Form',
        priority     => 25,
        requirement  => 'REQUIRED',
      }
      keycloak_flow_execution { 'script-user-enabled-authenticator.js under form-browser-with-duo on test':
        ensure      => 'present',
        requirement => 'REQUIRED',
        priority    => 35,
      }
      PUPPET_PP

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
        form = data.find { |d| d['displayName'] == 'form-browser-with-duo' }
        expect(form['index']).to eq(2)
        cookie = data.find { |d| d['providerId'] == 'auth-cookie' }
        expect(cookie['index']).to eq(1)
        idp = data.find { |d| d['providerId'] == 'identity-provider-redirector' }
        expect(idp['index']).to eq(0)
        auth_form = data.find { |d| d['providerId'] == 'auth-username-password-form' }
        expect(auth_form['index']).to eq(1)
        duo = data.find { |d| d['providerId'] == 'duo-universal' }
        expect(duo['index']).to eq(0)
        script = data.find { |d| d['authenticationConfig'] == 'script-user-enabled-authenticator.js' }
        expect(script['index']).to eq(2)
      end
    end
  end

  context 'when ensure => absent' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_flow { 'browser-with-duo on test':
        ensure => 'absent',
      }
      keycloak_flow_execution { 'auth-cookie under browser-with-duo on test':
        ensure => 'absent',
      }
      keycloak_flow_execution { 'identity-provider-redirector under browser-with-duo on test':
        ensure => 'absent',
      }
      PUPPET_PP

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
