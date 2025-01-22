require 'spec_helper'

describe Puppet::Type.type(:keycloak_client) do
  let(:default_config) do
    {
      name: 'foo',
      realm: 'test',
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
    expect(resource[:name]).to eq('foo')
  end

  it 'has client_id default to name' do
    expect(resource[:client_id]).to eq('foo')
  end

  it 'has id default to name' do
    expect(resource[:id]).to eq('foo')
  end

  it 'has realm' do
    expect(resource[:realm]).to eq('test')
  end

  it 'handles componsite name' do
    component = described_class.new(name: 'foo on test')
    expect(component[:name]).to eq('foo on test')
    expect(component[:client_id]).to eq('foo')
    expect(component[:realm]).to eq('test')
  end

  it 'defaults to client_authenticator_type=client-secret' do
    expect(resource[:client_authenticator_type]).to eq('client-secret')
  end

  it 'defaults to protocol=openid-connect' do
    expect(resource[:protocol]).to eq('openid-connect')
  end

  it 'does not allow invalid protocol' do
    config[:protocol] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  defaults = {
    enabled: :true,
    standard_flow_enabled: :true,
    implicit_flow_enabled: :false,
    direct_access_grants_enabled: :true,
    service_accounts_enabled: :false,
    public_client: :false,
    bearer_only: :false,
    full_scope_allowed: :true,
    default_client_scopes: [],
    optional_client_scopes: [],
    redirect_uris: [],
    web_origins: [],
    login_theme: :absent,
    browser_flow: :absent,
    direct_grant_flow: :absent,
  }

  describe 'basic properties' do
    # Test basic properties
    [
      :secret,
      :login_theme,
      :backchannel_logout_url,
      :backchannel_logout_session_required,
      :backchannel_logout_revoke_offline_tokens,
      :root_url,
      :admin_url,
      :base_url,
      :browser_flow,
      :direct_grant_flow,
      :saml_name_id_format,
      :saml_artifact_binding_url,
      :saml_single_logout_service_url_redirect,
      :saml_assertion_consumer_url_post,
      :saml_encrypt,
      :saml_assertion_signature,
      :saml_signing_certificate,
      :saml_encryption_certificate,
      :saml_signing_private_key,
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

  describe 'boolean properties' do
    # Test boolean properties
    [
      :enabled,
      :standard_flow_enabled,
      :implicit_flow_enabled,
      :direct_access_grants_enabled,
      :service_accounts_enabled,
      :public_client,
      :bearer_only,
      :full_scope_allowed,
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
      :redirect_uris,
      :web_origins,
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

  it 'autorequires keycloak_realm' do
    keycloak_realm = Puppet::Type.type(:keycloak_realm).new(name: 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_realm
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_realm.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires keycloak_client_scope' do
    config[:default_client_scopes] = ['foo']
    keycloak_client_scope = Puppet::Type.type(:keycloak_client_scope).new(name: 'foo', realm: 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_client_scope
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_client_scope.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires client_scope protocol mappers' do
    config[:default_client_scopes] = ['foo']
    keycloak_protocol_mapper = Puppet::Type.type(:keycloak_protocol_mapper).new(name: 'bar', realm: 'test', client_scope: 'foo')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_protocol_mapper
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_protocol_mapper.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires browser flow' do
    config[:browser_flow] = 'foo'
    flow = Puppet::Type.type(:keycloak_flow).new(name: 'foo', realm: 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource flow
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(flow.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end
end
