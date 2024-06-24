# frozen_string_literal: true

require 'spec_helper'

describe 'keycloak::spi_deployment' do
  on_supported_os.each do |os, facts|
    context "when #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/dne')
      end
      let(:version) { '24.0.5' }
      let(:title) { 'duo-spi' }
      let(:params) { { deployed_name: 'keycloak-duo-spi-jar-with-dependencies.jar', source: 'https://example.com/files/keycloak-duo-spi-jar-with-dependencies.jar' } }

      it do
        is_expected.to contain_archive('duo-spi').with(
          ensure: 'present',
          extract: 'false',
          path: "/opt/keycloak-#{version}/tmp/keycloak-duo-spi-jar-with-dependencies.jar",
          source: 'https://example.com/files/keycloak-duo-spi-jar-with-dependencies.jar',
          creates: "/opt/keycloak-#{version}/tmp/keycloak-duo-spi-jar-with-dependencies.jar",
          user: 'keycloak',
          group: 'keycloak',
          require: "File[/opt/keycloak-#{version}/tmp]",
          before: "File[/opt/keycloak-#{version}/providers/keycloak-duo-spi-jar-with-dependencies.jar]",
        )
      end

      it do
        is_expected.to contain_file("/opt/keycloak-#{version}/providers/keycloak-duo-spi-jar-with-dependencies.jar").with(
          ensure: 'file',
          source: "/opt/keycloak-#{version}/tmp/keycloak-duo-spi-jar-with-dependencies.jar",
          owner: 'keycloak',
          group: 'keycloak',
          mode: '0644',
          require: 'Class[Keycloak::Install]',
          notify: 'Class[Keycloak::Service]',
        )
      end
    end
  end
end
