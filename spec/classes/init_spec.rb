require 'spec_helper'

describe 'keycloak' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/dne')
      end

      case facts[:osfamily]
      when %r{RedHat}
        shell = '/sbin/nologin'
      when %r{Debian}
        shell = '/usr/sbin/nologin'
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('keycloak') }
      it { is_expected.to contain_class('keycloak::params') }

      it { is_expected.to contain_class('keycloak::install').that_comes_before('Class[keycloak::config]') }
      it { is_expected.to contain_class('keycloak::config').that_comes_before('Class[keycloak::service]') }
      it { is_expected.to contain_class('keycloak::service') }

      context 'keycloak::install' do
        it do
          is_expected.to contain_user('keycloak').only_with(ensure: 'present',
                                                            name: 'keycloak',
                                                            forcelocal: 'true',
                                                            shell: shell,
                                                            gid: 'keycloak',
                                                            home: '/var/lib/keycloak',
                                                            managehome: 'true')
        end
      end

      context 'keycloak::datasource::mysql' do
        let(:params) { { datasource_driver: 'mysql' } }

        it { is_expected.to contain_class('keycloak::install').that_comes_before('Class[keycloak::datasource::mysql]') }
        it { is_expected.to contain_class('keycloak::datasource::mysql').that_comes_before('Class[keycloak::config]') }

        it do
          is_expected.to contain_mysql__db('keycloak').with(user: 'sa',
                                                            password: 'sa',
                                                            host: 'localhost',
                                                            grant: 'ALL')
        end

        context 'manage_datasource => false' do
          let(:params) { { datasource_driver: 'mysql', manage_datasource: false } }

          it { is_expected.not_to contain_mysql__db('keycloak') }
        end
      end

      context 'keycloak::datasource::postgresql' do
        let(:params) { { datasource_driver: 'postgresql' } }

        it { is_expected.to contain_class('keycloak::install').that_comes_before('Class[keycloak::datasource::postgresql]') }
        it { is_expected.to contain_class('keycloak::datasource::postgresql').that_comes_before('Class[keycloak::config]') }

        it do
          is_expected.to contain_postgresql__server__db('keycloak').with(user: 'sa',
                                                                         password: %r{.*})
        end

        context 'manage_datasource => false' do
          let(:params) { { datasource_driver: 'postgresql', manage_datasource: false } }

          it { is_expected.not_to contain_postgresql__server__db('keycloak') }
        end
      end

      context 'keycloak::config' do
        it do
          is_expected.to contain_file('kcadm-wrapper.sh').only_with(
            ensure: 'file',
            path: '/opt/keycloak-4.2.1.Final/bin/kcadm-wrapper.sh',
            owner: 'keycloak',
            group: 'keycloak',
            mode: '0750',
            content: %r{.*},
            show_diff: 'false',
          )
        end

        it do
          is_expected.to contain_exec('create-keycloak-admin')
            .with(command: '/opt/keycloak-4.2.1.Final/bin/add-user-keycloak.sh --user admin --password changeme --realm master && touch /opt/keycloak-4.2.1.Final/.create-keycloak-admin-h2',
                  creates: '/opt/keycloak-4.2.1.Final/.create-keycloak-admin-h2',
                  notify: 'Class[Keycloak::Service]')
        end

        it do
          is_expected.to contain_file('/opt/keycloak-4.2.1.Final/config.cli').only_with(
            ensure: 'file',
            owner: 'keycloak',
            group: 'keycloak',
            mode: '0600',
            content: %r{.*},
            notify: 'Exec[jboss-cli.sh --file=config.cli]',
            show_diff: 'false',
          )
        end
      end

      context 'keycloak::service' do
        it do
          is_expected.to contain_service('keycloak').only_with(ensure: 'running',
                                                               enable: 'true',
                                                               name: 'keycloak',
                                                               hasstatus: 'true',
                                                               hasrestart: 'true')
        end
      end
    end # end context
  end # end on_supported_os loop
end # end describe
