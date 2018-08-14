require 'spec_helper_acceptance'

describe 'keycloak_client_protocol_mapper type:' do
  context 'creates protocol_mapper' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_client { 'test.foo.bar':
        realm         => 'test',
        redirect_uris => ['https://test.foo.bar/test1'],
        secret        => 'foobar',
      }
      keycloak_client_protocol_mapper { "username for test.foo.bar on test":
        claim_name     => 'preferred_username',
        user_attribute => 'username',
      }
      keycloak_client_protocol_mapper { "full name for test.foo.bar on test":
        type                 => 'oidc-full-name-mapper',
        userinfo_token_claim => false,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have created client protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
      end
    end

    it 'should have created protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'full name' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-full-name-mapper')
        expect(mapper['config']['userinfo.token.claim']).to eq('false')
      end
    end
  end

  context 'updates protocol_mapper' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_client { 'test.foo.bar':
        realm         => 'test',
        redirect_uris => ['https://test.foo.bar/test1'],
        secret        => 'foobar',
      }
      keycloak_client_protocol_mapper { "username for test.foo.bar on test":
        claim_name           => 'preferred_username',
        user_attribute       => 'username',
        userinfo_token_claim => false,
      }
      keycloak_client_protocol_mapper { "full name for test.foo.bar on test":
        type                 => 'oidc-full-name-mapper',
        userinfo_token_claim => true,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have updated protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['userinfo.token.claim']).to eq('false')
      end
    end

    it 'should have updated protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'full name' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-full-name-mapper')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
      end
    end
  end
end
