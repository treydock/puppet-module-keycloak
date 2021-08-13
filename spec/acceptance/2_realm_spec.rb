require 'spec_helper_acceptance'

describe 'keycloak_realm:', if: RSpec.configuration.keycloak_full do
  context 'creates realm' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test':
        ensure                                   => 'present',
        smtp_server_host                         => 'smtp.example.org',
        smtp_server_port                         => 587,
        smtp_server_starttls                     => false,
        smtp_server_auth                         => false,
        smtp_server_user                         => 'john',
        smtp_server_password                     => 'secret',
        smtp_server_envelope_from                => 'keycloak@id.example.org',
        smtp_server_from                         => 'keycloak@id.example.org',
        smtp_server_from_display_name            => 'Keycloak',
        smtp_server_reply_to                     => 'webmaster@example.org',
        smtp_server_reply_to_display_name        => 'Webmaster',
        brute_force_protected                    => false,
        roles                                    => ['offline_access', 'uma_authorization', 'new_role'],
        access_code_lifespan                     => 60,
        access_code_lifespan_login               => 1800,
        access_code_lifespan_user_action         => 300,
        access_token_lifespan                    => 60,
        access_token_lifespan_for_implicit_flow  => 900,
        action_token_generated_by_admin_lifespan => 43200,
        action_token_generated_by_user_lifespan  => 300,
        sso_session_idle_timeout_remember_me     => 0,
        sso_session_max_lifespan_remember_me     => 0,
        sso_session_idle_timeout                 => 1800,
        sso_session_max_lifespan                 => 36000,
        offline_session_idle_timeout             => 2592000,
        offline_session_max_lifespan             => 5184000,
        offline_session_max_lifespan_enabled     => true,
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a realm' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('test')
        expect(data['bruteForceProtected']).to eq(false)
        expect(data['registrationAllowed']).to eq(false)
        expect(data['resetPasswordAllowed']).to eq(false)
        expect(data['verifyEmail']).to eq(false)
      end
    end

    it 'has left default-client-scopes' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test/default-default-client-scopes' do
        data = JSON.parse(stdout)
        names = data.map { |d| d['name'] }.sort
        expect(names).to include('email')
        expect(names).to include('profile')
        expect(names).to include('role_list')
      end
    end

    it 'has left optional-client-scopes' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test/default-optional-client-scopes' do
        data = JSON.parse(stdout)
        names = data.map { |d| d['name'] }.sort
        expect(names).to include('address')
        expect(names).to include('offline_access')
        expect(names).to include('phone')
      end
    end

    it 'has default events config' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get events/config -r test' do
        data = JSON.parse(stdout)
        expect(data['eventsEnabled']).to eq(false)
        expect(data['eventsExpiration']).to be_nil
        expect(data['eventsListeners']).to eq(['jboss-logging'])
        expect(data['adminEventsEnabled']).to eq(false)
        expect(data['adminEventsDetailsEnabled']).to eq(false)
      end
    end

    it 'has correct smtp settings' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test' do
        data = JSON.parse(stdout)
        expect(data['smtpServer']['host']).to eq('smtp.example.org')
        expect(data['smtpServer']['port']).to eq('587')
        expect(data['smtpServer']['starttls']).to eq('false')
        expect(data['smtpServer']['auth']).to eq('false')
        expect(data['smtpServer']['user']).to eq('john')
        expect(data['smtpServer']['envelopeFrom']).to eq('keycloak@id.example.org')
        expect(data['smtpServer']['from']).to eq('keycloak@id.example.org')
        expect(data['smtpServer']['fromDisplayName']).to eq('Keycloak')
        expect(data['smtpServer']['replyTo']).to eq('webmaster@example.org')
        expect(data['smtpServer']['replyToDisplayName']).to eq('Webmaster')
      end
    end

    it 'has correct token settings' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test' do
        data = JSON.parse(stdout)
        expect(data['accessCodeLifespan']).to eq(60)
        expect(data['accessCodeLifespanLogin']).to eq(1800)
        expect(data['accessCodeLifespanUserAction']).to eq(300)
        expect(data['accessTokenLifespan']).to eq(60)
        expect(data['accessTokenLifespanForImplicitFlow']).to eq(900)
        expect(data['actionTokenGeneratedByAdminLifespan']).to eq(43_200)
        expect(data['actionTokenGeneratedByUserLifespan']).to eq(300)
        expect(data['ssoSessionIdleTimeoutRememberMe']).to eq(0)
        expect(data['ssoSessionMaxLifespanRememberMe']).to eq(0)
        expect(data['ssoSessionIdleTimeout']).to eq(1800)
        expect(data['ssoSessionMaxLifespan']).to eq(36_000)
        expect(data['offlineSessionIdleTimeout']).to eq(2_592_000)
        expect(data['offlineSessionMaxLifespan']).to eq(5_184_000)
        expect(data['offlineSessionMaxLifespanEnabled']).to eq(true)
      end
    end

    it 'has correct roles settings' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get roles -r test' do
        data = JSON.parse(stdout)
        expected_roles = ['new_role', 'offline_access', 'uma_authorization']
        realm_roles = []
        data.each do |d|
          unless d['composite']
            realm_roles.push(d['name'])
          end
        end
        expect(expected_roles - realm_roles).to eq([])
      end
    end
  end

  context 'updates realm' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test':
        ensure => 'present',
        remember_me => true,
        registration_allowed => true,
        reset_password_allowed => true,
        verify_email => true,
        access_code_lifespan => 3600,
        access_token_lifespan => 3600,
        access_code_lifespan_login => 3600,
        access_code_lifespan_user_action => 600,
        sso_session_idle_timeout => 3600,
        sso_session_max_lifespan => 72000,
        access_token_lifespan_for_implicit_flow  => 3600,
        action_token_generated_by_admin_lifespan => 21600,
        action_token_generated_by_user_lifespan  => 600,
        offline_session_idle_timeout             => 1296000,
        offline_session_max_lifespan             => 2592000,
        offline_session_max_lifespan_enabled     => false,
        default_client_scopes => ['profile'],
        content_security_policy => "frame-src https://*.duosecurity.com/ 'self'; frame-src 'self'; frame-ancestors 'self'; object-src 'none';",
        events_enabled => true,
        events_expiration => 2678400,
        admin_events_enabled => true,
        admin_events_details_enabled => true,
        smtp_server_host                  => 'smtp.example.org',
        smtp_server_port                  => 587,
        smtp_server_starttls              => false,
        smtp_server_auth                  => true,
        smtp_server_user                  => 'jane',
        smtp_server_password              => 'secret',
        smtp_server_envelope_from         => 'keycloak@id.example.org',
        smtp_server_from                  => 'keycloak@id.example.org',
        smtp_server_from_display_name     => 'Keycloak',
        smtp_server_reply_to              => 'webmaster@example.org',
        smtp_server_reply_to_display_name => 'Hostmaster',
        brute_force_protected             => true,
        roles                             => ['uma_authorization', 'new_role', 'other_new_role'],
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated the realm' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test' do
        data = JSON.parse(stdout)
        expect(data['rememberMe']).to eq(true)
        expect(data['registrationAllowed']).to eq(true)
        expect(data['resetPasswordAllowed']).to eq(true)
        expect(data['verifyEmail']).to eq(true)
        expect(data['accessCodeLifespan']).to eq(3600)
        expect(data['accessCodeLifespanLogin']).to eq(3600)
        expect(data['accessCodeLifespanUserAction']).to eq(600)
        expect(data['accessTokenLifespan']).to eq(3600)
        expect(data['accessTokenLifespanForImplicitFlow']).to eq(3600)
        expect(data['actionTokenGeneratedByAdminLifespan']).to eq(21_600)
        expect(data['actionTokenGeneratedByUserLifespan']).to eq(600)
        expect(data['ssoSessionIdleTimeout']).to eq(3600)
        expect(data['ssoSessionMaxLifespan']).to eq(72_000)
        expect(data['offlineSessionIdleTimeout']).to eq(1_296_000)
        expect(data['offlineSessionMaxLifespan']).to eq(2_592_000)
        expect(data['offlineSessionMaxLifespanEnabled']).to eq(false)
        expect(data['browserSecurityHeaders']['contentSecurityPolicy']).to eq("frame-src https://*.duosecurity.com/ 'self'; frame-src 'self'; frame-ancestors 'self'; object-src 'none';")
        expect(data['smtpServer']['host']).to eq('smtp.example.org')
        expect(data['smtpServer']['port']).to eq('587')
        expect(data['smtpServer']['starttls']).to eq('false')
        expect(data['smtpServer']['auth']).to eq('true')
        expect(data['smtpServer']['user']).to eq('jane')
        expect(data['smtpServer']['envelopeFrom']).to eq('keycloak@id.example.org')
        expect(data['smtpServer']['from']).to eq('keycloak@id.example.org')
        expect(data['smtpServer']['fromDisplayName']).to eq('Keycloak')
        expect(data['smtpServer']['replyTo']).to eq('webmaster@example.org')
        expect(data['smtpServer']['replyToDisplayName']).to eq('Hostmaster')
        expect(data['bruteForceProtected']).to eq(true)
      end
    end

    it 'has updated the realm default-client-scopes' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test/default-default-client-scopes' do
        data = JSON.parse(stdout)
        names = data.map { |d| d['name'] }
        expect(names).to eq(['profile'])
      end
    end

    it 'has updated events config' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get events/config -r test' do
        data = JSON.parse(stdout)
        expect(data['eventsEnabled']).to eq(true)
        expect(data['eventsExpiration']).to eq(2_678_400)
        expect(data['eventsListeners']).to eq(['jboss-logging'])
        expect(data['adminEventsEnabled']).to eq(true)
        expect(data['adminEventsDetailsEnabled']).to eq(true)
      end
    end

    it 'has updated roles settings' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get roles -r test' do
        data = JSON.parse(stdout)
        expected_roles = ['new_role', 'other_new_role', 'uma_authorization']
        realm_roles = []
        data.each do |d|
          unless d['composite']
            realm_roles.push(d['name'])
          end
        end
        expect(expected_roles - realm_roles).to eq([])
      end
    end
  end

  context 'creates realm with invalid browser flow' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test2':
        ensure       => 'present',
        browser_flow => 'Copy of browser',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, expect_changes: true)
    end

    it 'has created a realm' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test2' do
        data = JSON.parse(stdout)
        expect(data['browserFlow']).to eq('browser')
      end
    end
  end
end
