# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'required action types:', if: RSpec.configuration.keycloak_full_batch2 do
  context 'when creates required action' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_required_action { 'webauthn-register on test':
        ensure       => 'present',
        display_name => 'Webauthn Register',
        default      => true,
        enabled      => true,
        priority     => 200,
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has configured a required action' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/required-actions/webauthn-register -r test' do
        data = JSON.parse(stdout)
        expect(data['alias']).to eq('webauthn-register')
        expect(data['defaultAction']).to eq(true)
        expect(data['enabled']).to eq(true)
        expect(data['priority']).to eq(200)
      end
    end

    it 'has the configured required action in list' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/required-actions -r test' do
        data = JSON.parse(stdout)
        webauthn = data.find { |d| d['alias'] == 'webauthn-register' }
        expect(webauthn['priority']).to eq(200)
      end
    end
  end

  context 'when updates required action' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_required_action { 'webauthn-register on test':
        ensure       => 'present',
        display_name => 'Webauthn Register',
        default      => true,
        enabled      => true,
        priority     => 100,
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a required action' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/required-actions/webauthn-register -r test' do
        data = JSON.parse(stdout)
        expect(data['priority']).to eq(100)
      end
    end
  end

  context 'when ensure => absent' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_required_action { 'webauthn-register on test':
        ensure => 'absent',
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has deleted a flow' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get authentication/required-actions -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['alias'] == 'webauthn-register' }[0]
        expect(d).to be_nil
      end
    end
  end

  context 'when required action with multiple realms' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_realm { 'test2': ensure => 'present' }
      keycloak_required_action { 'webauthn-register on test':
        ensure       => 'present',
        display_name => 'Webauthn Register',
        default      => true,
        enabled      => true,
        priority     => 200,
      }
      keycloak_required_action { 'webauthn-register on test2':
        ensure       => 'present',
        display_name => 'Webauthn Register',
        default      => true,
        enabled      => true,
        priority     => 200,
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
