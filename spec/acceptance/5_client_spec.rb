require 'spec_helper_acceptance'

describe 'keycloak_client define:' do
  context 'creates client' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak::client_template { 'openid-connect-clients':
        realm => 'test',
      }
      keycloak_client { 'test.foo.bar':
        realm => 'test',
        redirect_uris   => ['https://test.foo.bar/test1'],
        client_template => 'openid-connect-clients',
        secret => 'foobar',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have created a client' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar -r test' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('test.foo.bar')
        expect(data['clientId']).to eq('test.foo.bar')
        expect(data['clientTemplate']).to eq('openid-connect-clients')
        expect(data['redirectUris']).to eq(['https://test.foo.bar/test1'])
      end
    end

    it 'should have set the client secret' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/client-secret -r test' do
        data = JSON.parse(stdout)
        expect(data['value']).to eq('foobar')
      end
    end
  end

  context 'updates client' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak::client_template { 'openid-connect-clients':
        realm => 'test',
      }
      keycloak_client { 'test.foo.bar':
        realm => 'test',
        redirect_uris   => ['https://test.foo.bar/test2'],
        client_template => 'openid-connect-clients',
        secret => 'foobar',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have updated a client' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar -r test' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('test.foo.bar')
        expect(data['clientId']).to eq('test.foo.bar')
        expect(data['clientTemplate']).to eq('openid-connect-clients')
        expect(data['redirectUris']).to eq(['https://test.foo.bar/test2'])
      end
    end

    it 'should have set the same client secret' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/client-secret -r test' do
        data = JSON.parse(stdout)
        expect(data['value']).to eq('foobar')
      end
    end
  end
end
