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
      keycloak_client { 'test.foo.bar':
        realm                 => 'test',
        redirect_uris         => ['https://test.foo.bar/test1'],
        default_client_scopes => ['address'],
        secret                => 'foobar',
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
        expect(data['defaultClientScopes']).to eq(['address'])
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
      keycloak_client { 'test.foo.bar':
        realm                 => 'test',
        redirect_uris         => ['https://test.foo.bar/test2'],
        default_client_scopes => ['profile', 'email'],
        secret                => 'foobar',
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
        expect(data['defaultClientScopes']).to eq(['profile', 'email'])
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
