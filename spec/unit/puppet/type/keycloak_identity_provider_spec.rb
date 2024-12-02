# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:keycloak_identity_provider) do
  let(:default_config) do
    {
      name: 'foo',
      realm: 'test',
      authorization_url: 'http://authorization',
      token_url: 'http://token',
      client_id: 'foobar',
      client_secret: 'secret'
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

  it 'has alias default to name' do
    expect(resource[:alias]).to eq('foo')
  end

  it 'has internal_id default to resource_name-realm' do
    expect(resource[:internal_id]).to eq('foo-test')
  end

  it 'has realm' do
    expect(resource[:realm]).to eq('test')
  end

  it 'handles componsite name' do
    component = described_class.new(name: 'foo on test')
    expect(component[:name]).to eq('foo on test')
    expect(component[:alias]).to eq('foo')
    expect(component[:realm]).to eq('test')
  end

  it 'defaults to provider_id=oidc' do
    expect(resource[:provider_id]).to eq('oidc')
  end

  it 'allows keycloak-oidc' do
    config[:provider_id] = 'keycloak-oidc'
    expect(resource[:provider_id]).to eq('keycloak-oidc')
  end

  it 'does not allow invalid provider_id' do
    config[:provider_id] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'defaults to update_profile_first_login_mode=on' do
    expect(resource[:update_profile_first_login_mode]).to eq('on')
  end

  it 'does not allow invalid update_profile_first_login_mode' do
    config[:update_profile_first_login_mode] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'defaults to prompt undefined' do
    expect(resource[:prompt]).to be_nil
  end

  it 'does not allow invalid prompt' do
    config[:prompt] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  defaults = {
    enabled: :true,
    trust_email: :false,
    store_token: :false,
    add_read_token_role_on_create: :false,
    authenticate_by_default: :false,
    link_only: :false,
    first_broker_login_flow_alias: 'first broker login',
    hide_on_login: :false,
    validate_signature: :false,
    ui_locales: :false,
    backchannel_supported: :false,
    use_jwks_url: :true,
    login_hint: :false,
    disable_user_info: :false
  }

  describe 'basic properties' do
    # Test basic properties
    [
      :display_name,
      :first_broker_login_flow_alias,
      :post_broker_login_flow_alias,
      :user_info_url,
      :client_id,
      :token_url,
      :authorization_url,
      :logout_url,
      :issuer,
      :default_scope,
      :allowed_clock_skew,
      :forward_parameters,
      :jwks_url
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
      :gui_order
    ].each do |p|
      it "accepts a #{p}" do
        config[p] = 100
        expect(resource[p]).to eq('100')
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
      :enabled,
      :trust_email,
      :store_token,
      :add_read_token_role_on_create,
      :authenticate_by_default,
      :link_only,
      :hide_on_login,
      :validate_signature,
      :ui_locales,
      :backchannel_supported,
      :use_jwks_url,
      :login_hint,
      :disable_user_info
    ].each do |p|
      it "accepts true for #{p}" do
        config[p] = true
        expect(resource[p]).to eq(:true)
        config[p] = 'true'
        expect(resource[p]).to eq(:true)
      end

      it "accepts false for #{p}" do
        config[p] = false
        expect(resource[p]).to eq(:false)
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
    [].each do |p|
      it 'accepts array' do
        config[p] = ['foo', 'bar']
        expect(resource[p]).to eq(['foo', 'bar'])
      end

      next unless defaults[p]

      it "has default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'client_auth_method' do
    [
      'client_secret_post', 'client_secret_basic', 'client_secret_jwt', 'private_key_jwt'
    ].each do |v|
      it "accepts #{v}" do
        config[:client_auth_method] = v
        expect(resource[:client_auth_method]).to eq(v)
      end
    end

    it 'does not accept invalid values' do
      config[:client_auth_method] = 'foo'
      expect { resource }.to raise_error(%r{Invalid})
    end
  end

  describe 'sync_mode' do
    [
      'IMPORT', 'LEGACY', 'FORCE'
    ].each do |v|
      it "accepts #{v}" do
        config[:sync_mode] = v
        expect(resource[:sync_mode]).to eq(v)
      end
    end

    it 'does not accept invalid values' do
      config[:sync_mode] = 'foo'
      expect { resource }.to raise_error(%r{Invalid})
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

  it 'autorequires browser flow' do
    config[:first_broker_login_flow_alias] = 'foo'
    flow = Puppet::Type.type(:keycloak_flow).new(name: 'foo', realm: 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource flow
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(flow.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'requires realm' do
    config[:ensure] = :present
    config[:provider_id] = 'oidc'
    config.delete(:realm)
    expect { resource }.to raise_error(Puppet::Error, %r{realm is required})
  end

  it 'requires authorization_url' do
    config[:ensure] = :present
    config[:provider_id] = 'oidc'
    config.delete(:authorization_url)
    expect { resource }.to raise_error(Puppet::Error, %r{authorization_url is required})
  end

  it 'requires token_url' do
    config[:ensure] = :present
    config[:provider_id] = 'oidc'
    config.delete(:token_url)
    expect { resource }.to raise_error(Puppet::Error, %r{token_url is required})
  end

  it 'requires client_id' do
    config[:ensure] = :present
    config[:provider_id] = 'oidc'
    config.delete(:client_id)
    expect { resource }.to raise_error(Puppet::Error, %r{client_id is required})
  end

  it 'requires client_secret' do
    config[:ensure] = :present
    config[:provider_id] = 'oidc'
    config.delete(:client_secret)
    expect { resource }.to raise_error(Puppet::Error, %r{client_secret is required})
  end
end
