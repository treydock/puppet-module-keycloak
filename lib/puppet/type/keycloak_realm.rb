# frozen_string_literal: true

require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'
require_relative '../../puppet_x/keycloak/integer_property'

Puppet::Type.newtype(:keycloak_realm) do
  desc <<-DESC
Manage Keycloak realms
@example Add a realm with a custom theme
  keycloak_realm { 'test':
    ensure                   => 'present',
    remember_me              => true,
    login_with_email_allowed => false,
    login_theme              => 'my_theme',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires(false)

  ensurable

  newparam(:name, namevar: true) do
    desc 'The realm name'
  end

  newparam(:id) do
    desc 'Id. Default to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:display_name) do
    desc 'displayName'
  end

  newproperty(:display_name_html) do
    desc 'displayNameHtml'
  end

  newproperty(:user_managed_access_allowed, boolean: true) do
    desc 'userManagedAccessAllowed'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:login_theme) do
    desc 'loginTheme'
    defaultto 'keycloak'
  end

  newproperty(:account_theme) do
    desc 'accountTheme'
    defaultto 'keycloak'
  end

  newproperty(:admin_theme) do
    desc 'adminTheme'
    defaultto 'keycloak'
  end

  newproperty(:email_theme) do
    desc 'emailTheme'
    defaultto 'keycloak'
  end

  newproperty(:internationalization_enabled, boolean: true) do
    desc 'internationalizationEnabled'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:default_locale) do
    desc 'defaultLocale'
  end

  newproperty(:sso_session_idle_timeout_remember_me, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'ssoSessionIdleTimeoutRememberMe'
  end

  newproperty(:sso_session_max_lifespan_remember_me, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'ssoSessionMaxLifespanRememberMe'
  end

  newproperty(:sso_session_idle_timeout, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'ssoSessionIdleTimeout'
  end

  newproperty(:sso_session_max_lifespan, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'ssoSessionMaxLifespan'
  end

  newproperty(:access_code_lifespan, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'accessCodeLifespan'
  end

  newproperty(:access_code_lifespan_login, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'accessCodeLifespanLogin'
  end

  newproperty(:access_code_lifespan_user_action, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'accessCodeLifespanUserAction'
  end

  newproperty(:access_token_lifespan, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'accessTokenLifespan'
  end

  newproperty(:access_token_lifespan_for_implicit_flow, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'accessTokenLifespanForImplicitFlow'
  end

  newproperty(:action_token_generated_by_admin_lifespan, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'actionTokenGeneratedByAdminLifespan'
  end

  newproperty(:action_token_generated_by_user_lifespan, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'actionTokenGeneratedByUserLifespan'
  end

  newproperty(:offline_session_idle_timeout, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'offlineSessionIdleTimeout'
  end

  newproperty(:offline_session_max_lifespan, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'offlineSessionMaxLifespan'
  end

  newproperty(:enabled, boolean: true) do
    desc 'enabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:remember_me, boolean: true) do
    desc 'rememberMe'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:registration_allowed, boolean: true) do
    desc 'registrationAllowed'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:login_with_email_allowed, boolean: true) do
    desc 'loginWithEmailAllowed'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:duplicate_emails_allowed, boolean: true) do
    desc 'duplicateEmailsAllowed'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:offline_session_max_lifespan_enabled, boolean: true) do
    desc 'offlineSessionMaxLifespanEnabled'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:reset_password_allowed, boolean: true) do
    desc 'resetPasswordAllowed'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:verify_email, boolean: true) do
    desc 'verifyEmail'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:ssl_required) do
    desc 'sslRequired'
    newvalues('none', 'all', 'external')
    defaultto 'external'
  end

  newproperty(:edit_username_allowed, boolean: true) do
    desc 'editUsernameAllowed'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:browser_flow) do
    desc 'browserFlow'
    defaultto('browser')
    munge { |v| v.to_s }
  end

  newproperty(:registration_flow) do
    desc 'registrationFlow'
    defaultto('registration')
    munge { |v| v.to_s }
  end

  newproperty(:direct_grant_flow) do
    desc 'directGrantFlow'
    defaultto('direct grant')
    munge { |v| v.to_s }
  end

  newproperty(:reset_credentials_flow) do
    desc 'resetCredentialsFlow'
    defaultto('reset credentials')
    munge { |v| v.to_s }
  end

  newproperty(:client_authentication_flow) do
    desc 'clientAuthenticationFlow'
    defaultto('clients')
    munge { |v| v.to_s }
  end

  newproperty(:docker_authentication_flow) do
    desc 'dockerAuthenticationFlow'
    defaultto('docker auth')
    munge { |v| v.to_s }
  end

  newproperty(:default_client_scopes, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'Default Client Scopes'
  end

  newproperty(:optional_client_scopes, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'Optional Client Scopes'
  end

  newproperty(:supported_locales, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'Supported Locales'
  end

  newproperty(:content_security_policy) do
    desc 'contentSecurityPolicy'
    defaultto("frame-src 'self'; frame-ancestors 'self'; object-src 'none';")
    munge { |v| v.to_s }
  end

  newproperty(:events_enabled, boolean: true) do
    desc 'eventsEnabled'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:events_expiration) do
    desc 'eventsExpiration'
  end

  newproperty(:events_listeners, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'eventsListeners'
    defaultto ['jboss-logging']
  end

  newproperty(:admin_events_enabled, boolean: true) do
    desc 'adminEventsEnabled'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:admin_events_details_enabled, boolean: true) do
    desc 'adminEventsDetailsEnabled'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:smtp_server_user) do
    desc 'smtpServer user'
  end

  newproperty(:smtp_server_password) do
    desc 'smtpServer password'

    def insync?(is)
      if is =~ %r{^\*+$}
        Puppet.warning("Property 'smtp_server_password' is set and Puppet has no way to check current value")
        true
      else
        false
      end
    end

    def should_to_s(_newvalue)
      '[new smtp_server_password redacted]'
    end
  end

  newproperty(:smtp_server_host) do
    desc 'smtpServer host'
  end

  newproperty(:smtp_server_port, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'smtpServer port'
  end

  newproperty(:smtp_server_auth, boolean: true) do
    desc 'smtpServer auth'
    newvalues(:true, :false)
  end

  newproperty(:smtp_server_starttls, boolean: true) do
    desc 'smtpServer starttls'
    newvalues(:true, :false)
  end

  newproperty(:smtp_server_ssl, boolean: true) do
    desc 'smtpServer ssl'
    newvalues(:true, :false)
  end

  newproperty(:smtp_server_from) do
    desc 'smtpServer from'
  end

  newproperty(:smtp_server_envelope_from) do
    desc 'smtpServer envelope_from'
  end

  newproperty(:smtp_server_from_display_name) do
    desc 'smtpServer fromDisplayName'
  end

  newproperty(:smtp_server_reply_to) do
    desc 'smtpServer replyto'
  end

  newproperty(:smtp_server_reply_to_display_name) do
    desc 'smtpServer replyToDisplayName'
  end

  newproperty(:brute_force_protected, boolean: true) do
    desc 'bruteForceProtected'
    newvalues(:true, :false)
  end

  newproperty(:permanent_lockout, boolean: true) do
    desc 'permanentLockout'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:max_failure_wait_seconds, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'maxFailureWaitSeconds'
    defaultto 900
  end

  newproperty(:minimum_quick_login_wait_seconds, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'minimumQuickLoginWaitSeconds'
    defaultto 60
  end

  newproperty(:wait_increment_seconds, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'waitIncrementSeconds'
    defaultto 60
  end

  newproperty(:quick_login_check_milli_seconds, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'quickLoginCheckMilliSeconds'
    defaultto 1_000
  end

  newproperty(:max_delta_time_seconds, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'maxDeltaTimeSeconds'
    defaultto 43_200
  end

  newproperty(:failure_factor, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'failureFactor'
    defaultto 30
  end

  newparam(:manage_roles, boolean: true) do
    desc 'Manage realm roles'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newproperty(:roles, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'roles'
    defaultto ['offline_access', 'uma_authorization']

    def insync?(is)
      if resource[:manage_roles].to_s == 'false'
        return true
      end

      super(is)
    end
  end

  newproperty(:web_authn_policy_rp_entity_name) do
    desc 'webAuthnPolicyRpEntityName'
    defaultto 'keycloak'
  end

  newproperty(:web_authn_policy_signature_algorithms, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'webAuthnPolicySignatureAlgorithms'
    defaultto ['ES256']
  end

  newproperty(:web_authn_policy_rp_id) do
    desc 'webAuthnPolicyRpId'
    defaultto ''
  end

  newproperty(:web_authn_policy_attestation_conveyance_preference) do
    desc 'webAuthnPolicyAttestationConveyancePreference'
    newvalues('none', 'direct', 'indirect', 'not specified')
    defaultto 'not specified'
  end

  newproperty(:web_authn_policy_authenticator_attachment) do
    desc 'webAuthnPolicyAuthenticatorAttachment'
    newvalues('platform', 'cross-platform', 'not specified')
    defaultto 'not specified'
  end

  newproperty(:web_authn_policy_require_resident_key) do
    desc 'webAuthnPolicyRequireResidentKey'
    newvalues('No', 'Yes', 'not specified')
    defaultto 'not specified'
  end

  newproperty(:web_authn_policy_user_verification_requirement) do
    desc 'webAuthnPolicyUserVerificationRequirement'
    newvalues('required', 'preferred', 'discouraged', 'not specified')
    defaultto 'not specified'
  end

  newproperty(:web_authn_policy_create_timeout, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'webAuthnPolicyCreateTimeout'
    defaultto 0
  end

  newproperty(:web_authn_policy_avoid_same_authenticator_register, boolean: true) do
    desc 'webAuthnPolicyAvoidSameAuthenticatorRegister'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:web_authn_policy_acceptable_aaguids, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'webAuthnPolicyAcceptableAaguids'
    defaultto []
  end

  newproperty(:custom_properties) do
    desc 'custom properties to pass as realm configurations'
    defaultto {}

    validate do |value|
      # rubocop:disable Style/SignalException
      fail 'custom_properties should be a Hash' unless value.is_a? ::Hash

      value.each_pair do |_k, v|
        fail 'custom_properties does not allow Hash values' if v.is_a? ::Hash
      end
      # rubocop:enable Style/SignalException
    end

    def insync?(is)
      should = @should
      should = should[0] if should.is_a?(Array)
      should.each_pair do |k, v|
        return false unless is.key?(k)

        case v
        when String, TrueClass, FalseClass
          return false if is[k].to_s != v.to_s
        when Array
          return false if is[k].sort != v.sort
        end
      end
      true
    end

    def change_to_s(currentvalue, newvalue)
      currentvalue = currentvalue.to_s if currentvalue != :absent
      newvalue = newvalue.to_s
      super(currentvalue, newvalue)
    end

    def is_to_s(currentvalue) # rubocop:disable Style/PredicateName
      currentvalue.to_s
    end
    alias_method :should_to_s, :is_to_s
  end
end
