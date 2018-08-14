require 'spec_helper_acceptance'

describe 'keycloak::client-template define:' do
  context 'creates client-template' do
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
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have created a client template' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients -r test' do
        data = JSON.parse(stdout)
        expect(data['name']).to eq('openid-connect-clients')
        expect(data['protocol']).to eq('openid-connect')
      end
    end

    it 'should have created protocol mapper email' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'email' }[0]
        expect(mapper['config']['claim.name']).to eq('email')
        expect(mapper['config']['user.attribute']).to eq('email')
      end
    end

    it 'should have created protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
      end
    end

    it 'should have created protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'full name' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-full-name-mapper')
        expect(mapper['config']['userinfo.token.claim']).to eq('false')
      end
    end

    it 'should have created protocol mapper family name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'family name' }[0]
        expect(mapper['config']['claim.name']).to eq('family_name')
        expect(mapper['config']['user.attribute']).to eq('lastName')
      end
    end

    it 'should have created protocol mapper given name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'given name' }[0]
        expect(mapper['config']['claim.name']).to eq('given_name')
        expect(mapper['config']['user.attribute']).to eq('firstName')
      end
    end
  end

  context 'creates saml client-template' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak::client_template { 'saml-clients':
        realm    => 'test',
        protocol => 'saml',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have created a client template' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients -r test' do
        data = JSON.parse(stdout)
        expect(data['name']).to eq('saml-clients')
        expect(data['protocol']).to eq('saml')
      end
    end

    it 'should have created protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.nameformat']).to eq('urn:oasis:names:tc:SAML:2.0:attrname-format:uri')
        expect(mapper['config']['attribute.name']).to eq('urn:oid:0.9.2342.19200300.100.1.1')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['friendly.name']).to eq('userid')
      end
    end

    it 'should have created protocol mapper X500 email' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'X500 email' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.nameformat']).to eq('urn:oasis:names:tc:SAML:2.0:attrname-format:uri')
        expect(mapper['config']['attribute.name']).to eq('urn:oid:1.2.840.113549.1.9.1')
        expect(mapper['config']['user.attribute']).to eq('email')
        expect(mapper['config']['friendly.name']).to eq('email')
      end
    end

    it 'should have created protocol mapper X500 givenName' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'X500 givenName' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.nameformat']).to eq('urn:oasis:names:tc:SAML:2.0:attrname-format:uri')
        expect(mapper['config']['attribute.name']).to eq('urn:oid:2.5.4.42')
        expect(mapper['config']['user.attribute']).to eq('firstName')
        expect(mapper['config']['friendly.name']).to eq('givenName')
      end
    end

    it 'should have created protocol mapper X500 surname' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'X500 surname' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.nameformat']).to eq('urn:oasis:names:tc:SAML:2.0:attrname-format:uri')
        expect(mapper['config']['attribute.name']).to eq('urn:oid:2.5.4.4')
        expect(mapper['config']['user.attribute']).to eq('lastName')
        expect(mapper['config']['friendly.name']).to eq('surname')
      end
    end

    it 'should have created protocol mapper role list' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'role list' }[0]
        expect(mapper['protocolMapper']).to eq('saml-role-list-mapper')
        expect(mapper['config']['attribute.nameformat']).to eq('Basic')
        expect(mapper['config']['attribute.name']).to eq('Role')
        expect(mapper['config']['single']).to eq('false')
      end
    end
  end
end
