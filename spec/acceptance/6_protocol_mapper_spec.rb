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
      keycloak_client_template { 'oidc on test':
        ensure => 'present',
      }
      keycloak_protocol_mapper { "username for oidc on test":
        consent_text   => '${username}',
        claim_name     => 'preferred_username',
        user_attribute => 'username',
      }
      keycloak_protocol_mapper { "full name for oidc on test":
        consent_text         => '${fullName}',
        type                 => 'oidc-full-name-mapper',
        userinfo_token_claim => false,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
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
      keycloak_client_template { 'oidc on test':
        ensure => 'present',
      }
      keycloak_protocol_mapper { "username for oidc on test":
        consent_text         => '${username}',
        claim_name           => 'preferred_username',
        user_attribute       => 'username',
        userinfo_token_claim => false,
      }
      keycloak_protocol_mapper { "full name for oidc on test":
        consent_text         => '${fullName}',
        type                 => 'oidc-full-name-mapper',
        userinfo_token_claim => true,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
