# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:keycloak_realm) do
  let(:default_config) do
    {
      name: 'test',
    }
  end
  let(:config) do
    default_config
  end
  let(:resource) do
    described_class.new(config)
  end

  it 'adds to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource resource
    }.not_to raise_error
  end

  it 'has a name' do
    expect(resource[:name]).to eq('test')
  end

  it 'has id default to name' do
    expect(resource[:id]).to eq('test')
  end

  defaults = {
    login_theme: 'keycloak',
    account_theme: 'keycloak',
    admin_theme: 'keycloak',
    email_theme: 'keycloak',
    user_managed_access_allowed: :false,
    access_code_lifespan_user_action: nil,
    access_token_lifespan_for_implicit_flow: nil,
    enabled: :true,
    remember_me: :false,
    login_with_email_allowed: :true,
    duplicate_emails_allowed: :false,
    ssl_required: 'external',
    registration_allowed: :false,
    edit_username_allowed: :false,
    browser_flow: 'browser',
    registration_flow: 'registration',
    direct_grant_flow: 'direct grant',
    reset_credentials_flow: 'reset credentials',
    client_authentication_flow: 'clients',
    docker_authentication_flow: 'docker auth',
    content_security_policy: "frame-src 'self'; frame-ancestors 'self'; object-src 'none';",
    events_enabled: :false,
    events_listeners: ['jboss-logging'],
    admin_events_enabled: :false,
    admin_events_details_enabled: :false,
    offline_session_max_lifespan_enabled: :false,
    internationalization_enabled: :false,
    permanent_lockout: :false,
    max_failure_wait_seconds: 900,
    minimum_quick_login_wait_seconds: 60,
    wait_increment_seconds: 60,
    quick_login_check_milli_seconds: 1_000,
    max_delta_time_seconds: 43_200,
    failure_factor: 30,
    otp_policy_type: 'totp',
    otp_policy_algorithm: 'HmacSHA1',
    otp_policy_initial_counter: 0,
    otp_policy_digits: 6,
    otp_policy_look_ahead_window: 1,
    otp_policy_period: 30,
    otp_policy_code_reusable: :false,
    web_authn_policy_rp_entity_name: 'keycloak',
    web_authn_policy_signature_algorithms: ['ES256'],
    web_authn_policy_rp_id: '',
    web_authn_policy_attestation_conveyance_preference: 'not specified',
    web_authn_policy_authenticator_attachment: 'not specified',
    web_authn_policy_require_resident_key: 'not specified',
    web_authn_policy_user_verification_requirement: 'not specified',
    web_authn_policy_create_timeout: 0,
    web_authn_policy_avoid_same_authenticator_register: :false,
    web_authn_policy_acceptable_aaguids: [],
    web_authn_policy_extra_origins: [],
    web_authn_policy_passwordless_rp_entity_name: 'keycloak',
    web_authn_policy_passwordless_signature_algorithms: ['ES256'],
    web_authn_policy_passwordless_rp_id: '',
    web_authn_policy_passwordless_attestation_conveyance_preference: 'not specified',
    web_authn_policy_passwordless_authenticator_attachment: 'not specified',
    web_authn_policy_passwordless_require_resident_key: 'not specified',
    web_authn_policy_passwordless_user_verification_requirement: 'not specified',
    web_authn_policy_passwordless_create_timeout: 0,
    web_authn_policy_passwordless_avoid_same_authenticator_register: :false,
    web_authn_policy_passwordless_acceptable_aaguids: [],
    web_authn_policy_passwordless_extra_origins: [],
  }

  describe 'otp_policy_digits' do
    it 'accepts 6 for otp_policy_digits' do
      config[:otp_policy_digits] = 6
      expect(resource[:otp_policy_digits]).to eq(6)
    end

    it 'accepts 8 for otp_policy_digits' do
      config[:otp_policy_digits] = 8
      expect(resource[:otp_policy_digits]).to eq(8)
    end

    it 'does not accept 7 for otp_policy_digits' do
      config[:otp_policy_digits] = 7
      expect {
        resource
      }.to raise_error(%r{7})
    end

    it 'does not accept 5 for otp_policy_digits' do
      config[:otp_policy_digits] = 5
      expect {
        resource
      }.to raise_error(%r{5})
    end

    it 'has default for otp_policy_digits' do
      expect(resource[:otp_policy_digits]).to eq(defaults[:otp_policy_digits])
    end

    it 'does not accept nil for otp_policy_digits' do
      config[:otp_policy_digits] = nil
      expect {
        resource
      }.to raise_error(%r{nil})
    end

    it 'does not accept empty for otp_policy_digits' do
      config[:otp_policy_digits] = ''
      expect {
        resource
      }.to raise_error(%r{Invalid value ""})
    end

    it 'does not accept foo for otp_policy_digits' do
      config[:otp_policy_digits] = 'foo'
      expect {
        resource
      }.to raise_error(%r{Invalid value "foo"})
    end
  end

  # Test enumerable properties
  describe 'enumerable properties' do
    {
      otp_policy_type: [:totp, :hotp],
      otp_policy_algorithm: [:HmacSHA1, :HmacSHA256, :HmacSHA512],
      web_authn_policy_attestation_conveyance_preference: [:none, :indirect, :direct],
      web_authn_policy_authenticator_attachment: [:platform, :'cross-platform'],
      web_authn_policy_require_resident_key: [:Yes, :No],
      web_authn_policy_user_verification_requirement: [:required, :preferred, :discouraged],
      web_authn_policy_passwordless_attestation_conveyance_preference: [:none, :indirect, :direct],
      web_authn_policy_passwordless_authenticator_attachment: [:platform, :'cross-platform'],
      web_authn_policy_passwordless_require_resident_key: [:Yes, :No],
      web_authn_policy_passwordless_user_verification_requirement: [:required, :preferred, :discouraged],
    }.each do |p, values|
      values.each do |v|
        it "accepts #{v} for #{p}" do
          config[p] = v
          expect(resource[p]).to eq(v)
        end
      end

      it "does not accept foo for #{p}" do
        config[p] = 'foo'
        expect {
          resource
        }.to raise_error(%r{foo})
      end

      it "does not accept empty for #{p}" do
        config[p] = ''
        expect {
          resource
        }.to raise_error(%r{Invalid value ""})
      end

      it "does not accept nil for #{p}" do
        config[p] = nil
        expect {
          resource
        }.to raise_error(%r{nil})
      end

      it "has default for #{p}" do
        expect(resource[p]).to eq(defaults[p].to_sym)
      end
    end
  end

  describe 'basic properties' do
    # Test basic properties
    [
      :display_name,
      :display_name_html,
      :login_theme,
      :account_theme,
      :admin_theme,
      :email_theme,
      :events_expiration,
      :browser_flow,
      :registration_flow,
      :direct_grant_flow,
      :reset_credentials_flow,
      :client_authentication_flow,
      :docker_authentication_flow,
      :content_security_policy,
      :smtp_server_user,
      :smtp_server_password,
      :smtp_server_host,
      :smtp_server_envelope_from,
      :smtp_server_from,
      :smtp_server_from_display_name,
      :smtp_server_reply_to,
      :smtp_server_reply_to_display_name,
      :default_locale,
      :password_policy,
      :web_authn_policy_rp_entity_name,
      :web_authn_policy_rp_id,
      :web_authn_policy_passwordless_rp_entity_name,
      :web_authn_policy_passwordless_rp_id,
    ].each do |p|
      it "accepts a #{p}" do
        config[p] = 'foo'
        expect(resource[p]).to eq('foo')
      end

      next unless defaults[p]

      it "has default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'integer properties' do
    # Test integer properties
    [
      :sso_session_idle_timeout_remember_me,
      :sso_session_max_lifespan_remember_me,
      :sso_session_idle_timeout,
      :sso_session_max_lifespan,
      :access_code_lifespan,
      :access_code_lifespan_login,
      :access_code_lifespan_user_action,
      :access_token_lifespan,
      :access_token_lifespan_for_implicit_flow,
      :action_token_generated_by_admin_lifespan,
      :action_token_generated_by_user_lifespan,
      :offline_session_idle_timeout,
      :offline_session_max_lifespan,
      :smtp_server_port,
      :max_failure_wait_seconds,
      :minimum_quick_login_wait_seconds,
      :wait_increment_seconds,
      :quick_login_check_milli_seconds,
      :max_delta_time_seconds,
      :failure_factor,
      :otp_policy_initial_counter,
      :otp_policy_look_ahead_window,
      :otp_policy_period,
      :web_authn_policy_create_timeout,
      :web_authn_policy_passwordless_create_timeout,
    ].each do |p|
      it "accepts a #{p}" do
        config[p] = 100
        expect(resource[p]).to eq(100)
      end

      next unless defaults[p]

      it "has default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'boolean properties' do
    # Test boolean properties
    [
      :user_managed_access_allowed,
      :remember_me,
      :registration_allowed,
      :reset_password_allowed,
      :verify_email,
      :login_with_email_allowed,
      :duplicate_emails_allowed,
      :edit_username_allowed,
      :internationalization_enabled,
      :manage_roles,
      :events_enabled,
      :admin_events_enabled,
      :admin_events_details_enabled,
      :smtp_server_auth,
      :smtp_server_starttls,
      :smtp_server_ssl,
      :brute_force_protected,
      :offline_session_max_lifespan_enabled,
      :permanent_lockout,
      :otp_policy_code_reusable,
    ].each do |p|
      it "accepts true for #{p}" do
        config[p] = true
        expect(resource[p]).to eq(:true)
      end

      it "accepts true for #{p} string" do
        config[p] = 'true'
        expect(resource[p]).to eq(:true)
      end

      it "accepts false for #{p}" do
        config[p] = false
        expect(resource[p]).to eq(:false)
      end

      it "accepts false for #{p} string" do
        config[p] = 'false'
        expect(resource[p]).to eq(:false)
      end

      it "does not accept strings for #{p}" do
        config[p] = 'foo'
        expect {
          resource
        }.to raise_error(%r{foo})
      end

      next unless defaults[p]

      it "has default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'array properties' do
    # Array properties
    [
      :default_client_scopes,
      :optional_client_scopes,
      :events_listeners,
      :supported_locales,
      :roles,
      :web_authn_policy_signature_algorithms,
      :web_authn_policy_acceptable_aaguids,
      :web_authn_policy_extra_origins,
      :web_authn_policy_passwordless_signature_algorithms,
      :web_authn_policy_passwordless_acceptable_aaguids,
      :web_authn_policy_passwordless_extra_origins,
    ].each do |p|
      it "accepts array for #{p}" do
        config[p] = ['foo', 'bar']
        expect(resource[p]).to eq(['foo', 'bar'])
      end

      next unless defaults[p]

      it "has default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'custom_properties' do
    it 'allow custom properties' do
      config[:custom_properties] = { 'foo' => 'bar' }
      expect(resource[:custom_properties]).to eq('foo' => 'bar')
    end

    it 'is in sync with default' do
      config[:custom_properties] = {}
      expect(resource.property(:custom_properties).insync?('foo' => 'bar')).to eq(true)
    end

    it 'is in sync with defined properties' do
      config[:custom_properties] = { 'foo' => 'bar' }
      expect(resource.property(:custom_properties).insync?('foo' => 'bar', 'bar' => 'baz')).to eq(true)
    end
  end

  it 'autorequires keycloak_conn_validator' do
    keycloak_conn_validator = Puppet::Type.type(:keycloak_conn_validator).new(name: 'keycloak')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_conn_validator
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_conn_validator.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires kcadm-wrapper.sh' do
    file = Puppet::Type.type(:file).new(name: 'kcadm-wrapper.sh', path: '/opt/keycloak/bin/kcadm-wrapper.sh')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource file
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(file.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end
end
