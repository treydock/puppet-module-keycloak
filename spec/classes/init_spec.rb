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

      context "keycloak::install" do
        it do
          is_expected.to contain_user('keycloak').only_with({
            :ensure     => 'present',
            :name       => 'keycloak',
            :forcelocal => 'true',
            :shell      => '/sbin/nologin',
            :gid        => 'keycloak',
            :home       => '/var/lib/keycloak',
            :managehome => 'true',
          })
        end
      end

      context "keycloak::config" do
        it do
          is_expected.to contain_exec('create-keycloak-admin').with({
            :command => '/opt/keycloak-3.4.1.Final/bin/add-user-keycloak.sh --user admin --password changeme --realm master && touch /opt/keycloak-3.4.1.Final/.create-keycloak-admin-h2',
            :creates => '/opt/keycloak-3.4.1.Final/.create-keycloak-admin-h2',
            :notify  => 'Class[Keycloak::Service]',
          })
        end
      end

      context "keycloak::service" do
        it do
          is_expected.to contain_service('keycloak').only_with({
            :ensure      => 'running',
            :enable      => 'true',
            :name        => 'keycloak',
            :hasstatus   => 'true',
            :hasrestart  => 'true',
          })
        end
      end

    end # end context
  end # end on_supported_os loop
end # end describe
