require 'spec_helper_acceptance'

describe 'keycloak_sssd_user_provider:' do
  context 'bootstrap sssd' do
    it 'is successful' do
      on hosts, 'puppet resource package sssd-dbus ensure=installed'
      on hosts, 'puppet resource package sssd-ldap ensure=installed'
      sssd_conf = <<-EOS
[domain/LDAP]
ldap_uri = ldap://localhost:389/
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap
access_provider = ldap

[sssd]
config_file_version = 2
debug_level = 0x02F0
domains = LDAP
services = ifp
      EOS
      create_remote_file(hosts, '/etc/sssd/sssd.conf', sssd_conf)
      on hosts, 'chmod 0600 /etc/sssd/sssd.conf'
      on hosts, 'systemctl restart dbus'
      on hosts, 'systemctl restart sssd'
    end
  end
  context 'creates sssd' do
    it 'runs successfully' do
      pp = <<-EOS
      service { 'sssd': ensure => 'running' }
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
        with_sssd_support => true,
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_sssd_user_provider { 'SSSD':
        ensure => 'present',
        realm => 'test',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a SSSD user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components/SSSD-test -r test' do
        data = JSON.parse(stdout)
        expect(data['config']['priority']).to eq(['0'])
        expect(data['config']['cachePolicy']).to eq(['DEFAULT'])
        expect(data['config']['enabled']).to eq(['true'])
      end
    end
  end

  context 'updates sssd' do
    it 'runs successfully' do
      pp = <<-EOS
      service { 'sssd': ensure => 'running' }
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
        with_sssd_support => true,
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_sssd_user_provider { 'SSSD':
        ensure => 'present',
        realm => 'test',
        priority => '1',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a SSSD user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components/SSSD-test -r test' do
        data = JSON.parse(stdout)
        expect(data['config']['priority']).to eq(['1'])
        expect(data['config']['cachePolicy']).to eq(['DEFAULT'])
        expect(data['config']['enabled']).to eq(['true'])
      end
    end
  end

  context 'deletes sssd' do
    it 'runs successfully' do
      pp = <<-EOS
      service { 'sssd': ensure => 'running' }
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
        with_sssd_support => true,
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_sssd_user_provider { 'SSSD':
        ensure => 'absent',
        realm => 'test',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has deleted a SSSD user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components/SSSD-test -r test', acceptable_exit_codes: [0, 1] do
        expect(exit_code).to eq(1)
      end
    end
  end
end
