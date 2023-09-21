# frozen_string_literal: true

require 'spec_helper'

describe 'keycloak::partial_import' do
  on_supported_os.each do |os, facts|
    context "when #{os}" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:facts) do
        facts.merge(concat_basedir: '/dne')
      end
      let(:version) { '22.0.0' }
      let(:title) { 'test' }
      let(:params) do
        {
          realm: 'myrealm',
          if_resource_exists: 'OVERWRITE',
          source: 'puppet:///modules/profile/keycloak/test.json'
        }
      end
      let(:file_path) { "/opt/keycloak-#{version}/conf/#{title}.json" }
      let(:command) do
        [
          "/opt/keycloak-#{version}/bin/kcadm-wrapper.sh create partialImport",
          "-r #{params[:realm]} -s ifResourceExists=#{params[:if_resource_exists]}",
          "-o -f #{file_path}"
        ].join(' ')
      end
      let(:pre_condition) do
        <<-PP
        keycloak_realm { #{params[:realm]}:
           ensure => 'present',
        }
        PP
      end

      it { is_expected.to compile.with_all_deps }

      it 'creates partial import JSON file' do
        is_expected.to contain_file(file_path).with(
          ensure: 'file',
          owner: 'keycloak',
          group: 'keycloak',
          mode: '0600',
          source: params[:source],
          content: nil,
          require: 'Class[Keycloak::Install]',
          notify: "Exec[partial-import-#{title}]",
        )
      end

      it 'creates exec for partial import' do
        is_expected.to create_exec("partial-import-#{title}").with(
          path: '/usr/bin:/bin:/usr/sbin:/sbin',
          command: "#{command} || { rm -f #{file_path}; exit 1; }",
          logoutput: 'true',
          refreshonly: 'true',
          require: 'Keycloak_conn_validator[keycloak]',
        )
      end

      it { is_expected.to contain_keycloak_realm(params[:realm]).that_comes_before("Exec[partial-import-#{title}]") }
    end
  end
end
