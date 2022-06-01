require 'spec_helper_acceptance'

describe 'keycloak class:', unless: RSpec.configuration.keycloak_full do
  context 'default parameters' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': db => 'dev-file' }
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

  context 'default with mysql/mariadb db' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('keycloak') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8080) do
      it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
    end
  end

  context 'default with postgresql db' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak':
        db => 'postgres',
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
      it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
    end
  end

  context 'changes to defaults' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak':
        java_opts => '-Xmx512m -Xms64m',
        configs   => {
          'metrics-enabled' => true,
        },
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
      it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
    end
  end

  context 'reset to defaults' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('keycloak') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8080) do
      it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
    end
  end
end
