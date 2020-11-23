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
    access_code_lifespan_user_action: nil,
    access_token_lifespan_for_implicit_flow: nil,
    enabled: :true,
    remember_me: :false,
    login_with_email_allowed: :true,
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
  }

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
    ].each do |p|
      it "should accept a #{p}" do
        config[p] = 'foo'
        expect(resource[p]).to eq('foo')
      end
      next unless defaults[p]
      it "should have default for #{p}" do
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
      :access_code_lifespan_user_action,
      :access_token_lifespan,
      :access_token_lifespan_for_implicit_flow,
      :smtp_server_port,
    ].each do |p|
      it "should accept a #{p}" do
        config[p] = 100
        expect(resource[p]).to eq(100)
      end
      next unless defaults[p]
      it "should have default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'boolean properties' do
    # Test boolean properties
    [
      :remember_me,
      :registration_allowed,
      :reset_password_allowed,
      :verify_email,
      :login_with_email_allowed,
      :internationalization_enabled,
      :events_enabled,
      :admin_events_enabled,
      :admin_events_details_enabled,
      :smtp_server_auth,
      :smtp_server_starttls,
      :smtp_server_ssl,
      :brute_force_protected,
    ].each do |p|
      it "should accept true for #{p}" do
        config[p] = true
        expect(resource[p]).to eq(:true)
      end
      it "should accept true for #{p} string" do
        config[p] = 'true'
        expect(resource[p]).to eq(:true)
      end
      it "should accept false for #{p}" do
        config[p] = false
        expect(resource[p]).to eq(:false)
      end
      it "should accept false for #{p} string" do
        config[p] = 'false'
        expect(resource[p]).to eq(:false)
      end
      it "should not accept strings for #{p}" do
        config[p] = 'foo'
        expect {
          resource
        }.to raise_error(%r{foo})
      end
      next unless defaults[p]
      it "should have default for #{p}" do
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
    ].each do |p|
      it "should accept array for #{p}" do
        config[p] = ['foo', 'bar']
        expect(resource[p]).to eq(['foo', 'bar'])
      end
      next unless defaults[p]
      it "should have default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
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
