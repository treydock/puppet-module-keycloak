# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'keycloak class:', unless: RSpec.configuration.keycloak_full do
  context 'with default parameters' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': db => 'dev-file' }
      PUPPET_PP

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

  context 'with default for mysql/mariadb db' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      PUPPET_PP

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
  end

  context 'with default for postgresql db' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak':
        db => 'postgres',
      }
      PUPPET_PP

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
  end

  context 'with changes to defaults' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak':
        http_relative_path => '/auth',
        java_opts          => '-Xmx512m -Xms64m -Djava.net.preferIPv4Stack=true',
        configs            => {
          'metrics-enabled' => true,
        },
      }
      PUPPET_PP

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
  end

  context 'with reset to defaults' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      PUPPET_PP

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
  end
end
