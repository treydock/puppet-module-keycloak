require 'spec_helper_acceptance'

describe 'keycloak_protocol_mapper type:' do
  context 'creates protocol_mapper' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_client_scope { 'oidc on test':
        ensure => 'present',
      }
      keycloak_protocol_mapper { "username for oidc on test":
        claim_name     => 'preferred_username',
        user_attribute => 'username',
      }
      keycloak_protocol_mapper { "full name for oidc on test":
        type                 => 'oidc-full-name-mapper',
        userinfo_token_claim => false,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have created a client scope' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc -r test' do
        data = JSON.parse(stdout)
        expect(data['name']).to eq('oidc')
        expect(data['protocol']).to eq('openid-connect')
      end
    end

    it 'should have created protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
      end
    end

    it 'should have created protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
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
      keycloak_client_scope { 'oidc on test':
        ensure => 'present',
      }
      keycloak_protocol_mapper { "username for oidc on test":
        claim_name           => 'preferred_username',
        user_attribute       => 'username',
        userinfo_token_claim => false,
      }
      keycloak_protocol_mapper { "full name for oidc on test":
        type                 => 'oidc-full-name-mapper',
        userinfo_token_claim => true,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have updated protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['userinfo.token.claim']).to eq('false')
      end
    end

    it 'should have updated protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'full name' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-full-name-mapper')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
      end
    end
  end

  context 'creates saml protocol_mapper' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_client_scope { 'saml on test':
        ensure => 'present',
        protocol => 'saml',
      }
      keycloak_protocol_mapper { "email for saml on test":
        protocol       => 'saml',
        type           => 'saml-user-property-mapper',
        user_attribute => 'email',
        friendly_name  => 'email',
        attribute_name => 'email',
      }
      keycloak_protocol_mapper { "firstName for saml on test":
        protocol       => 'saml',
        type           => 'saml-user-property-mapper',
        user_attribute => 'firstName',
        friendly_name  => 'firstName',
        attribute_name => 'firstName',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have created a client scope' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml -r test' do
        data = JSON.parse(stdout)
        expect(data['name']).to eq('saml')
        expect(data['protocol']).to eq('saml')
      end
    end

    it 'should have created protocol mapper email' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'email' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.name']).to eq('email')
        expect(mapper['config']['user.attribute']).to eq('email')
        expect(mapper['config']['friendly.name']).to eq('email')
      end
    end

    it 'should have created protocol mapper firstName' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'firstName' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.name']).to eq('firstName')
        expect(mapper['config']['user.attribute']).to eq('firstName')
        expect(mapper['config']['friendly.name']).to eq('firstName')
      end
    end
  end
end
