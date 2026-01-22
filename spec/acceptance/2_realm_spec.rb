# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'keycloak_realm:', if: RSpec.configuration.keycloak_full do
  context 'when creates realm' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
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
      keycloak_realm { 'test realm':
        ensure => 'present',
      }
      keycloak::partial_import { 'test':
        realm              => 'test',
        if_resource_exists => 'OVERWRITE',
        source             => 'file:///tmp/partial-import.json',
      }
      PUPPET_PP

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
        expect(data['sslRequired']).to eq('external')
        expect(data['editUsernameAllowed']).to eq(false)
        expect(data['internationalizationEnabled']).to eq(false)
      end
    end

    it 'created a realm with space in name' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test%20realm' do
        data = JSON.parse(stdout)
        expect(data['id']).to eq('test realm')
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

    it 'imports a client' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get clients -r test' do
        data = JSON.parse(stdout)
        client = data.find { |d| d['clientId'] == 'test.example.com' }
        expect(client['clientId']).to eq('test.example.com')
      end
    end
  end

  context 'when updates realm' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test':
        ensure => 'present',
        remember_me => true,
        registration_allowed => true,
        login_with_email_allowed => false,
        duplicate_emails_allowed => true,
        reset_password_allowed => true,
        verify_email => true,
        user_managed_access_allowed => true,
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
        login_theme                       => 'keycloak.v2',
        account_theme                     => 'keycloak.v2',
        admin_theme                       => 'keycloak.v2',
        email_theme                       => 'keycloak.v2',
        internationalization_enabled      => true,
        default_locale                    => 'en',
        supported_locales                 => ['en','de'],
        custom_properties                 => {
          'revokeRefreshToken' => true,
        },
        failure_factor                    => 60,
        permanent_lockout                 => true,
        max_failure_wait_seconds          => 999,
        minimum_quick_login_wait_seconds  => 40,
        wait_increment_seconds            => 10,
        quick_login_check_milli_seconds   => 10,
        max_delta_time_seconds            => 3600,
        otp_policy_type                   => 'totp',
        otp_policy_algorithm              => 'HmacSHA512',
        otp_policy_initial_counter        => 1,
        otp_policy_digits                 => 8,
        otp_policy_period                 => 30,
        otp_policy_code_reusable          => true,
        password_policy                   => 'length(12) and notUsername(undefined) and notEmail(undefined) and forceExpiredPasswordChange(365) and hashIterations(27500) and passwordHistory(3) and specialChars(1) and upperCase(1) and lowerCase(1) and digits(1) and maxLength(64)',
        web_authn_policy_rp_entity_name                    => 'Keycloak',
        web_authn_policy_signature_algorithms              => ['ES256', 'ES384', 'ES512', 'RS256', 'RS384', 'RS512'],
        web_authn_policy_rp_id                             => 'https://example.com',
        web_authn_policy_attestation_conveyance_preference => 'direct',
        web_authn_policy_authenticator_attachment          => 'cross-platform',
        web_authn_policy_require_resident_key              => 'No',
        web_authn_policy_user_verification_requirement     => 'required',
        web_authn_policy_create_timeout                    => 600,
        web_authn_policy_avoid_same_authenticator_register => true,
        web_authn_policy_acceptable_aaguids                => ['d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1'],
        web_authn_policy_extra_origins                     => ['https://example.com'],
        web_authn_policy_passwordless_rp_entity_name                    => 'Keycloak',
        web_authn_policy_passwordless_signature_algorithms              => ['ES256', 'ES384', 'ES512', 'RS256', 'RS384', 'RS512'],
        web_authn_policy_passwordless_rp_id                             => 'https://example.com',
        web_authn_policy_passwordless_attestation_conveyance_preference => 'direct',
        web_authn_policy_passwordless_authenticator_attachment          => 'cross-platform',
        web_authn_policy_passwordless_require_resident_key              => 'No',
        web_authn_policy_passwordless_user_verification_requirement     => 'required',
        web_authn_policy_passwordless_create_timeout                    => 600,
        web_authn_policy_passwordless_avoid_same_authenticator_register => true,
        web_authn_policy_passwordless_acceptable_aaguids                => ['d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1'],
        web_authn_policy_passwordless_extra_origins                     => ['https://example.com'],
      }
      PUPPET_PP

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated the realm' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get realms/test' do
        password_policy_value = [
          'length(12)',
          'notUsername(undefined)',
          'notEmail(undefined)',
          'forceExpiredPasswordChange(365)',
          'hashIterations(27500)',
          'passwordHistory(3)',
          'specialChars(1)',
          'upperCase(1)',
          'lowerCase(1)',
          'digits(1)',
          'maxLength(64)'
        ]

        data = JSON.parse(stdout)
        expect(data['rememberMe']).to eq(true)
        expect(data['registrationAllowed']).to eq(true)
        expect(data['loginWithEmailAllowed']).to eq(false)
        expect(data['duplicateEmailsAllowed']).to eq(true)
        expect(data['resetPasswordAllowed']).to eq(true)
        expect(data['verifyEmail']).to eq(true)
        expect(data['userManagedAccessAllowed']).to eq(true)
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
        expect(data['loginTheme']).to eq('keycloak.v2')
        expect(data['accountTheme']).to eq('keycloak.v2')
        expect(data['adminTheme']).to eq('keycloak.v2')
        expect(data['emailTheme']).to eq('keycloak.v2')
        expect(data['failureFactor']).to eq(60)
        expect(data['permanentLockout']).to eq(true)
        expect(data['maxFailureWaitSeconds']).to eq(999)
        expect(data['minimumQuickLoginWaitSeconds']).to eq(40)
        expect(data['waitIncrementSeconds']).to eq(10)
        expect(data['quickLoginCheckMilliSeconds']).to eq(10)
        expect(data['maxDeltaTimeSeconds']).to eq(3600)
        expect(data['revokeRefreshToken']).to eq(true)
        expect(data['internationalizationEnabled']).to eq(true)
        expect(data['defaultLocale']).to eq('en')
        expect(data['supportedLocales']).to eq(['de', 'en'])
        expect(data['otpPolicyType']).to eq('totp')
        expect(data['otpPolicyAlgorithm']).to eq('HmacSHA512')
        expect(data['otpPolicyInitialCounter']).to eq(1)
        expect(data['otpPolicyDigits']).to eq(8)
        expect(data['otpPolicyPeriod']).to eq(30)
        expect(data['otpPolicyCodeReusable']).to eq(true)
        expect(data['passwordPolicy']).to eq(password_policy_value.join(' and '))
        expect(data['webAuthnPolicyRpEntityName']).to eq('Keycloak')
        expect(data['webAuthnPolicySignatureAlgorithms']).to eq(['ES256', 'ES384', 'ES512', 'RS256', 'RS384', 'RS512'])
        expect(data['webAuthnPolicyRpId']).to eq('https://example.com')
        expect(data['webAuthnPolicyAttestationConveyancePreference']).to eq('direct')
        expect(data['webAuthnPolicyAuthenticatorAttachment']).to eq('cross-platform')
        expect(data['webAuthnPolicyRequireResidentKey']).to eq('No')
        expect(data['webAuthnPolicyUserVerificationRequirement']).to eq('required')
        expect(data['webAuthnPolicyCreateTimeout']).to eq(600)
        expect(data['webAuthnPolicyAvoidSameAuthenticatorRegister']).to eq(true)
        expect(data['webAuthnPolicyAcceptableAaguids']).to eq(['d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1'])
        expect(data['webAuthnPolicyExtraOrigins']).to eq(['https://example.com'])
        expect(data['webAuthnPolicyPasswordlessRpEntityName']).to eq('Keycloak')
        expect(data['webAuthnPolicyPasswordlessSignatureAlgorithms']).to eq(['ES256', 'ES384', 'ES512', 'RS256', 'RS384', 'RS512'])
        expect(data['webAuthnPolicyPasswordlessRpId']).to eq('https://example.com')
        expect(data['webAuthnPolicyPasswordlessAttestationConveyancePreference']).to eq('direct')
        expect(data['webAuthnPolicyPasswordlessAuthenticatorAttachment']).to eq('cross-platform')
        expect(data['webAuthnPolicyPasswordlessRequireResidentKey']).to eq('No')
        expect(data['webAuthnPolicyPasswordlessUserVerificationRequirement']).to eq('required')
        expect(data['webAuthnPolicyPasswordlessCreateTimeout']).to eq(600)
        expect(data['webAuthnPolicyPasswordlessAvoidSameAuthenticatorRegister']).to eq(true)
        expect(data['webAuthnPolicyPasswordlessAcceptableAaguids']).to eq(['d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1'])
        expect(data['webAuthnPolicyPasswordlessExtraOrigins']).to eq(['https://example.com'])
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

  context 'when creates realm with invalid browser flow' do
    it 'runs successfully' do
      pp = <<-PUPPET_PP
      class { 'keycloak': }
      keycloak_realm { 'test2':
        ensure       => 'present',
        browser_flow => 'Copy of browser',
      }
      PUPPET_PP

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
