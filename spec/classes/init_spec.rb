require 'spec_helper'

describe 'keycloak' do
  on_supported_os({
    :supported_os => [
      {
        "operatingsystem" => "RedHat",
        "operatingsystemrelease" => ["7"],
      }
    ]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/dne',
        })
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('keycloak') }
      it { is_expected.to contain_class('keycloak::params') }

      it { is_expected.to contain_class('keycloak::install').that_comes_before('Class[keycloak::config]') }
      it { is_expected.to contain_class('keycloak::config').that_comes_before('Class[keycloak::service]') }
      it { is_expected.to contain_class('keycloak::service') }

      include_context 'keycloak::install'
      include_context 'keycloak::config'
      include_context 'keycloak::service'

      # Test validate_bool parameters
      [

      ].each do |param|
        context "with #{param} => 'foo'" do
          let(:params) {{ param.to_sym => 'foo' }}
          it 'should raise an error' do
            expect { is_expected.to compile }.to raise_error(/is not a boolean/)
          end
        end
      end

    end # end context
  end # end on_supported_os loop
end # end describe
