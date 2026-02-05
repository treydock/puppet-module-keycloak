# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'keycloak_api:', if: RSpec.configuration.keycloak_full_batch1 do
  context 'when bootstraps' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'when creates realm' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      keycloak_api { 'keycloak':
        install_dir => '/opt/keycloak',
      }
      keycloak_realm { 'test2': ensure => 'present' }
      PUPPET_PP

      on hosts, 'rm -f /opt/keycloak/bin/kcadm-wrapper.sh'
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a realm' do
      on hosts, '/opt/keycloak/bin/kcadm.sh get realms/test2 --no-config --server http://127.0.0.1:8080 --realm master --user admin --password changeme' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('test2')
      end
    end
  end

  context 'when updates realm' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      keycloak_api { 'keycloak':
        install_dir => '/opt/keycloak',
      }
      keycloak_realm { 'test2':
        ensure => 'present',
        remember_me => true,
      }
      PUPPET_PP

      on hosts, 'rm -f /opt/keycloak/bin/kcadm-wrapper.sh'
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a realm' do
      on hosts, '/opt/keycloak/bin/kcadm.sh get realms/test2 --no-config --server http://127.0.0.1:8080 --realm master --user admin --password changeme' do
        data = JSON.parse(stdout)
        expect(data['rememberMe']).to eq(true)
      end
    end
  end
end
