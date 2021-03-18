require 'spec_helper'

describe 'keycloak' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/dne')
      end
      let(:version) { '12.0.4' }

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

      context 'domain master' do
        let(:params) do
          {
            operating_mode: 'domain',
            install_dir: '/opt/keycloak-x',
            role: 'master',
            datasource_driver: 'postgresql',
            wildfly_user: 'wildfly',
            wildfly_user_password: 'changeme',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_augeas('ensure-servername').with(incl: '/opt/keycloak-x/domain/configuration/host-master.xml')
          is_expected.to contain_exec('create-wildfly-user').with(command: '/opt/keycloak-x/bin/add-user.sh --user wildfly --password changeme -e -s && touch /opt/keycloak-x/.create-wildfly-user')
        end
      end

      context 'domain slave' do
        let(:params) do
          {
            operating_mode: 'domain',
            install_dir: '/opt/keycloak-x',
            role: 'slave',
            master_address: '10.0.5.10',
            datasource_driver: 'postgresql',
            wildfly_user: 'wildfly',
            wildfly_user_password: 'changeme',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_augeas('ensure-servername').with(incl: '/opt/keycloak-x/domain/configuration/host-slave.xml',
                                                                  context: '/files/opt/keycloak-x/domain/configuration/host-slave.xml/host/servers')
          is_expected.to contain_exec('create-wildfly-user').with(command: '/opt/keycloak-x/bin/add-user.sh --user wildfly --password changeme -e -s && touch /opt/keycloak-x/.create-wildfly-user')
        end
      end

      context 'standalone with domain role defined' do
        let(:params) do
          {
            operating_mode: 'standalone',
            role: 'master',
          }
        end

        it { is_expected.not_to compile }
      end

      context 'domain slave without master_address' do
        let(:params) do
          {
            operating_mode: 'domain',
            wildfly_user: 'wildfly',
            wildfly_user_password: 'wildfly',
            role: 'slave',
          }
        end

        it { is_expected.not_to compile }
      end

      context 'domain master without wildfly user' do
        let(:params) do
          {
            operating_mode: 'domain',
            role: 'master',
            wildfly_user_password: 'wildfly',
          }
        end

        it { is_expected.not_to compile }
      end

      context 'domain master without wildfly user password' do
        let(:params) do
          {
            operating_mode: 'domain',
            role: 'master',
            wildfly_user: 'wildfly',
          }
        end

        it { is_expected.not_to compile }
      end

      context 'keycloak::install' do
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

      context 'keycloak::datasource::mysql' do
        let(:pre_condition) { 'include ::mysql::server' }
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
            path: "/opt/keycloak-#{version}/bin/kcadm-wrapper.sh",
            owner: 'keycloak',
            group: 'keycloak',
            mode: '0750',
            content: %r{.*},
            show_diff: 'false',
          )
        end

        it do
          is_expected.to contain_exec('create-keycloak-admin')
            .with(command: "/opt/keycloak-#{version}/bin/add-user-keycloak.sh --user admin --password changeme --realm master && touch /opt/keycloak-#{version}/.create-keycloak-admin-h2",
                  creates: "/opt/keycloak-#{version}/.create-keycloak-admin-h2",
                  notify: 'Class[Keycloak::Service]')
        end

        it do
          is_expected.to contain_file("/opt/keycloak-#{version}/standalone/configuration").only_with(
            ensure: 'directory',
            owner: 'keycloak',
            group: 'keycloak',
            mode: '0750',
          )
        end

        it do
          is_expected.to contain_file("/opt/keycloak-#{version}/standalone/configuration/profile.properties").only_with(
            ensure: 'file',
            owner: 'keycloak',
            group: 'keycloak',
            mode: '0644',
            content: %r{.*},
            notify: 'Class[Keycloak::Service]',
          )
        end

        it do
          verify_exact_file_contents(catalogue, "/opt/keycloak-#{version}/standalone/configuration/profile.properties", [])
        end

        it do
          is_expected.to contain_concat("/opt/keycloak-#{version}/config.cli").with(
            ensure: 'present',
            owner: 'keycloak',
            group: 'keycloak',
            mode: '0600',
            notify: 'Exec[jboss-cli.sh --file=config.cli]',
            show_diff: 'false',
          )
        end

        it do
          is_expected.to contain_file_line('keycloak-JAVA_OPTS').with(
            ensure: 'absent',
            path: "/opt/keycloak-#{version}/bin/standalone.conf",
            line: 'JAVA_OPTS="$JAVA_OPTS "',
            match: '^JAVA_OPTS=',
            notify: 'Class[Keycloak::Service]',
          )
        end

        context 'when tech_preview_features defined' do
          let(:params) { { tech_preview_features: ['account_api'] } }

          it do
            verify_exact_file_contents(catalogue, "/opt/keycloak-#{version}/standalone/configuration/profile.properties", ['feature.account_api=enabled'])
          end
        end

        context 'when java_opts defined' do
          let(:params) { { java_opts: '-Xmx512m -Xms64m' } }

          it do
            is_expected.to contain_file_line('keycloak-JAVA_OPTS').with(
              ensure: 'present',
              path: "/opt/keycloak-#{version}/bin/standalone.conf",
              line: 'JAVA_OPTS="$JAVA_OPTS -Xmx512m -Xms64m"',
              match: '^JAVA_OPTS=',
              notify: 'Class[Keycloak::Service]',
            )
          end

          context 'when java_opts_append is false' do
            let(:params) { { java_opts: '-Xmx512m -Xms64m', java_opts_append: false } }

            it do
              is_expected.to contain_file_line('keycloak-JAVA_OPTS').with(
                ensure: 'present',
                path: "/opt/keycloak-#{version}/bin/standalone.conf",
                line: 'JAVA_OPTS="-Xmx512m -Xms64m"',
                match: '^JAVA_OPTS=',
                notify: 'Class[Keycloak::Service]',
              )
            end
          end
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

      context 'syslog support' do
        let(:params) { { syslog: true, install_dir: '/opt/keycloak-x' } }
        it do
          is_expected.to contain_concat_fragment('keycloak-config.cli-syslog').with(target: '/opt/keycloak-x/config.cli', order: '12')
        end
      end

    end # end context
  end # end on_supported_os loop
end # end describe
