# frozen_string_literal: true

require 'spec_helper'

describe 'keycloak' do
  on_supported_os.each do |os, facts|
    context "when #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/dne')
      end
      let(:version) { '25.0.1' }

      case facts[:osfamily]
      when %r{RedHat}
        shell = '/sbin/nologin'
      when %r{Debian}
        shell = '/usr/sbin/nologin'
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('keycloak') }

      it { is_expected.to contain_class('keycloak::install').that_comes_before('Class[keycloak::config]') }
      it { is_expected.to contain_class('keycloak::config').that_comes_before('Class[keycloak::service]') }
      it { is_expected.to contain_class('keycloak::service') }

      describe 'keycloak::install' do
        it do
          is_expected.to contain_user('keycloak').only_with(ensure: 'present',
                                                            name: 'keycloak',
                                                            forcelocal: 'true',
                                                            shell: shell,
                                                            gid: 'keycloak',
                                                            home: '/var/lib/keycloak',
                                                            managehome: 'true',
                                                            system: 'true')
        end
      end

      context 'when keycloak db=mysql' do
        let(:pre_condition) { 'include ::mysql::server' }
        let(:params) { { db: 'mysql' } }

        it { is_expected.to contain_class('keycloak::db::mysql').that_notifies('Class[keycloak::service]') }

        it do
          is_expected.to contain_mysql__db('keycloak').with(user: 'keycloak',
                                                            password: 'changeme',
                                                            host: 'localhost',
                                                            grant: 'ALL')
        end

        it do
          verify_contents(catalogue, "/opt/keycloak-#{version}/conf/keycloak.conf", [
                            'db=mysql'
                          ])
        end

        context 'when manage_db => false' do
          let(:params) { { db: 'mysql', manage_db: false } }

          it { is_expected.not_to contain_mysql__db('keycloak') }
        end
      end

      context 'when keycloak db=mariadb' do
        let(:pre_condition) { 'include ::mysql::server' }
        let(:params) { { db: 'mariadb' } }

        it { is_expected.to contain_class('keycloak::db::mariadb').that_notifies('Class[keycloak::service]') }

        it do
          is_expected.to contain_mysql__db('keycloak').with(user: 'keycloak',
                                                            password: 'changeme',
                                                            host: 'localhost',
                                                            grant: 'ALL')
        end

        it do
          verify_contents(catalogue, "/opt/keycloak-#{version}/conf/keycloak.conf", [
                            'db=mariadb'
                          ])
        end

        context 'when manage_db => false' do
          let(:params) { { db: 'mariadb', manage_db: false } }

          it { is_expected.not_to contain_mysql__db('keycloak') }
        end
      end

      context 'when keycloak db=postgres' do
        let(:params) { { db: 'postgres' } }

        it { is_expected.to contain_class('keycloak::db::postgres').that_notifies('Class[keycloak::service]') }

        it do
          is_expected.to contain_postgresql__server__db('keycloak').with(user: 'keycloak',
                                                                         password: %r{.*})
        end

        it do
          verify_contents(catalogue, "/opt/keycloak-#{version}/conf/keycloak.conf", [
                            'db=postgres'
                          ])
        end

        context 'when manage_db => false' do
          let(:params) { { db: 'postgres', manage_db: false } }

          it { is_expected.not_to contain_postgresql__server__db('keycloak') }
        end
      end

      describe 'keycloak::config' do
        it do
          is_expected.to contain_file('kcadm-wrapper.sh').only_with(
            ensure: 'file',
            path: "/opt/keycloak-#{version}/bin/kcadm-wrapper.sh",
            owner: 'root',
            group: 'root',
            mode: '0750',
            source: 'puppet:///modules/keycloak/kcadm-wrapper.sh',
            show_diff: 'false',
            require: 'File[kcadm-wrapper.conf]',
          )
        end

        it do
          verify_exact_file_contents(catalogue, "/opt/keycloak-#{version}/conf/keycloak.conf", [
                                       "hostname=#{facts[:fqdn]}",
                                       'http-enabled=true',
                                       'http-host=0.0.0.0',
                                       'http-port=8080',
                                       'https-port=8443',
                                       'http-relative-path=/',
                                       'db=dev-file',
                                       'db-url-database=keycloak',
                                       'db-username=keycloak',
                                       'db-password=changeme',
                                       'proxy=none'
                                     ])
        end

        context 'when hostname is unset' do
          let(:params) { { hostname: 'unset' } }

          it do
            is_expected.to contain_file("/opt/keycloak-#{version}/conf/keycloak.conf").without_content(%r{^hostname=})
          end
        end

        context 'when http_enabled => false' do
          let(:params) { { http_enabled: false } }

          it do
            verify_contents(catalogue, "/opt/keycloak-#{version}/conf/keycloak.conf", ['http-enabled=false'])
          end
        end

        context 'when features defined' do
          let(:params) { { features: ['authorization', 'impersonation'] } }

          it do
            verify_contents(catalogue, "/opt/keycloak-#{version}/conf/keycloak.conf", ['features=authorization,impersonation'])
          end
        end
      end

      describe 'keycloak::service' do
        it do
          is_expected.to contain_systemd__unit_file('keycloak.service').with(
            content: %r{ExecStart=/opt/keycloak-#{version}/bin/kc.sh start$},
          )
        end

        it do
          is_expected.to contain_service('keycloak').only_with(ensure: 'running',
                                                               enable: 'true',
                                                               name: 'keycloak',
                                                               hasstatus: 'true',
                                                               hasrestart: 'true')
        end

        context 'when java_opts defined' do
          let(:params) { { java_opts: '-Xmx512m -Xms64m' } }

          it do
            is_expected.to contain_systemd__unit_file('keycloak.service').with(
              content: %r{Environment='JAVA_OPTS_APPEND=-Xmx512m -Xms64m'},
            )
          end
        end

        context 'when java_home defined' do
          let(:params) { { java_home: '/foo' } }

          it do
            is_expected.to contain_systemd__unit_file('keycloak.service').with(
              content: %r{Environment='JAVA_HOME=/foo'},
            )
          end
        end
      end
    end
  end
end
