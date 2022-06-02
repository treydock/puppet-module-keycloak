require 'spec_helper_acceptance'

describe 'keycloak_client_protocol_mapper type:', if: RSpec.configuration.keycloak_full do
  context 'creates protocol_mapper' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
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
      keycloak_client_protocol_mapper { "groups for test.foo.bar on test":
        type       => 'oidc-group-membership-mapper',
        claim_name => 'groups',
      }
      keycloak_client_protocol_mapper { "foo for test.foo.bar on test":
        type                     => 'oidc-audience-mapper',
        included_client_audience => 'foo',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created client protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
      end
    end

    it 'has created protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'full name' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-full-name-mapper')
        expect(mapper['config']['userinfo.token.claim']).to eq('false')
      end
    end

    it 'has created protocol mapper groups' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'groups' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-group-membership-mapper')
        expect(mapper['config']['full.path']).to eq('false')
        expect(mapper['config']['id.token.claim']).to eq('true')
        expect(mapper['config']['access.token.claim']).to eq('true')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
        expect(mapper['config']['claim.name']).to eq('groups')
      end
    end

    it 'has created protocol mapper audience' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'foo' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-audience-mapper')
        expect(mapper['config']['id.token.claim']).to eq('true')
        expect(mapper['config']['access.token.claim']).to eq('true')
        expect(mapper['config']['included.client.audience']).to eq('foo')
      end
    end
  end

  context 'updates protocol_mapper' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
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
      keycloak_client_protocol_mapper { "groups for test.foo.bar on test":
        type       => 'oidc-group-membership-mapper',
        claim_name => 'groups',
        full_path  => true,
      }
      keycloak_client_protocol_mapper { "foo for test.foo.bar on test":
        type                     => 'oidc-audience-mapper',
        included_client_audience => 'foo',
        id_token_claim           => false,
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['userinfo.token.claim']).to eq('false')
      end
    end

    it 'has updated protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'full name' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-full-name-mapper')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
      end
    end

    it 'has updated protocol mapper groups' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'groups' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-group-membership-mapper')
        expect(mapper['config']['full.path']).to eq('true')
        expect(mapper['config']['id.token.claim']).to eq('true')
        expect(mapper['config']['access.token.claim']).to eq('true')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
        expect(mapper['config']['claim.name']).to eq('groups')
      end
    end

    it 'has updated protocol mapper audience' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients/test.foo.bar/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'foo' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-audience-mapper')
        expect(mapper['config']['id.token.claim']).to eq('false')
        expect(mapper['config']['access.token.claim']).to eq('true')
        expect(mapper['config']['included.client.audience']).to eq('foo')
      end
    end
  end
end
