# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'keycloak_protocol_mapper type:', if: RSpec.configuration.keycloak_full_batch2 do
  context 'when creates protocol_mapper' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
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
      keycloak_protocol_mapper { "groups for oidc on test":
        type       => 'oidc-group-membership-mapper',
        claim_name => 'groups',
      }
      keycloak_protocol_mapper { "foo for oidc on test":
        type                     => 'oidc-audience-mapper',
        included_client_audience => 'foo',
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a client scope' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc -r test' do
        data = JSON.parse(stdout)
        expect(data['name']).to eq('oidc')
        expect(data['protocol']).to eq('openid-connect')
      end
    end

    it 'has created protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
      end
    end

    it 'has created protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'full name' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-full-name-mapper')
        expect(mapper['config']['userinfo.token.claim']).to eq('false')
      end
    end

    it 'has created protocol mapper groups' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
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
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'foo' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-audience-mapper')
        expect(mapper['config']['id.token.claim']).to eq('true')
        expect(mapper['config']['access.token.claim']).to eq('true')
        expect(mapper['config']['included.client.audience']).to eq('foo')
      end
    end
  end

  context 'when updates protocol_mapper' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
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
      keycloak_protocol_mapper { "groups for oidc on test":
        type       => 'oidc-group-membership-mapper',
        claim_name => 'groups',
        full_path  => true,
      }
      keycloak_protocol_mapper { "foo for oidc on test":
        type                     => 'oidc-audience-mapper',
        included_client_audience => 'foo',
        id_token_claim           => false,
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated protocol mapper username' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'username' }[0]
        expect(mapper['config']['claim.name']).to eq('preferred_username')
        expect(mapper['config']['user.attribute']).to eq('username')
        expect(mapper['config']['userinfo.token.claim']).to eq('false')
      end
    end

    it 'has updated protocol mapper full name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'full name' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-full-name-mapper')
        expect(mapper['config']['userinfo.token.claim']).to eq('true')
      end
    end

    it 'has updated protocol mapper groups' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
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
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/oidc/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'foo' }[0]
        expect(mapper['protocolMapper']).to eq('oidc-audience-mapper')
        expect(mapper['config']['id.token.claim']).to eq('false')
        expect(mapper['config']['access.token.claim']).to eq('true')
        expect(mapper['config']['included.client.audience']).to eq('foo')
      end
    end
  end

  context 'when creates saml protocol_mapper' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak':
        features => ['scripts'],
      }
      keycloak::spi_deployment { 'osc-keycloak-scripts':
        deployed_name => 'osc-keycloak-scripts-jar-with-dependencies.jar',
        source        => 'https://github.com/OSC/osc-keycloak-scripts/releases/download/1.1.0/osc-keycloak-scripts-1.1.0-jar-with-dependencies.jar',
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
      keycloak_protocol_mapper { 'x500 displayName for saml on test':
        protocol             => 'saml',
        type                 => 'script-x500-displayName.js',
        attribute_nameformat => 'uri',
        friendly_name        => 'displayName',
        attribute_name       => 'urn:oid:2.16.840.1.113730.3.1.241',
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a client scope' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml -r test' do
        data = JSON.parse(stdout)
        expect(data['name']).to eq('saml')
        expect(data['protocol']).to eq('saml')
      end
    end

    it 'has created protocol mapper email' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'email' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.name']).to eq('email')
        expect(mapper['config']['user.attribute']).to eq('email')
        expect(mapper['config']['friendly.name']).to eq('email')
      end
    end

    it 'has created protocol mapper firstName' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'firstName' }[0]
        expect(mapper['protocolMapper']).to eq('saml-user-property-mapper')
        expect(mapper['config']['attribute.name']).to eq('firstName')
        expect(mapper['config']['user.attribute']).to eq('firstName')
        expect(mapper['config']['friendly.name']).to eq('firstName')
      end
    end

    it 'has created protocol mapper from script' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get client-scopes/saml/protocol-mappers/models -r test' do
        data = JSON.parse(stdout)
        mapper = data.select { |d| d['name'] == 'x500 displayName' }[0]
        expect(mapper['protocolMapper']).to eq('script-x500-displayName.js')
        expect(mapper['config']['attribute.name']).to eq('urn:oid:2.16.840.1.113730.3.1.241')
        expect(mapper['config']['attribute.nameformat']).to eq('URI Reference')
        expect(mapper['config']['friendly.name']).to eq('displayName')
      end
    end
  end
end
