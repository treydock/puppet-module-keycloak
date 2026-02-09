# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'keycloak client scopes defines:', if: RSpec.configuration.keycloak_full_batch1 do
  context 'when creates client scopes' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak::client_scope::oidc { 'openid-connect-clients':
        realm => 'test',
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a client scope' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients -r test' do
        data = JSON.parse(stdout)
        expect(data['name']).to eq('openid-connect-clients')
        expect(data['protocol']).to eq('openid-connect')
      end
    end

    it 'has created protocol mapper email' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'email' }[0]
        expect(mapper['config']['claim.name']).to eq('email')
        expect(mapper['config']['user.attribute']).to eq('email')
      end
    end

    it 'has created protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
      end
    end

    it 'has created protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'full name' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-full-name-mapper')
        expect(mapper['config']['userinfo.token.claim']).to eq('false')
      end
    end

    it 'has created protocol mapper family name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'family name' }[0]
        expect(mapper['config']['claim.name']).to eq('family_name')
        expect(mapper['config']['user.attribute']).to eq('lastName')
      end
    end

    it 'has created protocol mapper given name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/openid-connect-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'given name' }[0]
        expect(mapper['config']['claim.name']).to eq('given_name')
        expect(mapper['config']['user.attribute']).to eq('firstName')
      end
    end
  end

  context 'when creates saml client scope' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak::client_scope::saml { 'saml-clients':
        realm => 'test',
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a client scope' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients -r test' do
        data = JSON.parse(stdout)
        expect(data['name']).to eq('saml-clients')
        expect(data['protocol']).to eq('saml')
      end
    end

    it 'has created protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.nameformat']).to eq('URI Reference')
        expect(mapper['config']['attribute.name']).to eq('urn:oid:0.9.2342.19200300.100.1.1')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['friendly.name']).to eq('userid')
      end
    end

    it 'has created protocol mapper X500 email' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'X500 email' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.nameformat']).to eq('URI Reference')
        expect(mapper['config']['attribute.name']).to eq('urn:oid:1.2.840.113549.1.9.1')
        expect(mapper['config']['user.attribute']).to eq('email')
        expect(mapper['config']['friendly.name']).to eq('email')
      end
    end

    it 'has created protocol mapper X500 givenName' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'X500 givenName' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.nameformat']).to eq('URI Reference')
        expect(mapper['config']['attribute.name']).to eq('urn:oid:2.5.4.42')
        expect(mapper['config']['user.attribute']).to eq('firstName')
        expect(mapper['config']['friendly.name']).to eq('givenName')
      end
    end

    it 'has created protocol mapper X500 surname' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml-clients/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'X500 surname' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.nameformat']).to eq('URI Reference')
        expect(mapper['config']['attribute.name']).to eq('urn:oid:2.5.4.4')
        expect(mapper['config']['user.attribute']).to eq('lastName')
        expect(mapper['config']['friendly.name']).to eq('surname')
      end
    end

    it 'has created protocol mapper role list' do
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
