require 'spec_helper_acceptance'

describe 'keycloak_client define:' do
  context 'creates client' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': }
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
  end

  context 'updates client' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': }
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
  end
end
