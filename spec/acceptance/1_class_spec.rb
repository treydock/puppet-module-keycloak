require 'spec_helper_acceptance'

describe 'keycloak class:' do
  context 'default parameters' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file("/opt/keycloak-#{RSpec.configuration.keycloak_version}") do
      it { is_expected.to be_directory }
    end

    describe service('keycloak') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'default with clustered mode enable' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak':
        operating_mode => 'clustered',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('keycloak') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'default with mysql datasource' do
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

    describe service('keycloak') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8080) do
      it { is_expected.to be_listening.on('0.0.0.0').with('tcp') }
    end

    describe port(9990) do
      it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
    end
  end

  context 'default with postgresql datasource' do
    it 'runs successfully' do
      pp = <<-EOS
      include postgresql::server
      class { 'keycloak':
        datasource_driver => 'postgresql',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('keycloak') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8080) do
      it { is_expected.to be_listening.on('0.0.0.0').with('tcp') }
    end

    describe port(9990) do
      it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
    end
  end

  context 'changes to defaults' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
        proxy_https       => true,
        service_java_opts => '-Xmx512m -Xms64m',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('keycloak') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8080) do
      it { is_expected.to be_listening.on('0.0.0.0').with('tcp') }
    end

    describe port(9990) do
      it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
    end
  end
end
