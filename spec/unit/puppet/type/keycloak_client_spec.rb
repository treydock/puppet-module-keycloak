require 'spec_helper'

describe Puppet::Type.type(:keycloak_client) do
  let(:default_config) do
    {
      :name => 'foo',
      :realm => 'test',
    }
  end
  let(:config) do
    default_config
  end
  let(:resource) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource resource
    }.to_not raise_error
  end

  it 'should have a name' do
    expect(resource[:name]).to eq('foo')
  end

  it 'should have client_id default to name' do
    expect(resource[:client_id]).to eq('foo')
  end

  it 'should have id default to name' do
    expect(resource[:id]).to eq('foo')
  end

  it 'should have realm' do
    expect(resource[:realm]).to eq('test')
  end

  it 'should handle componsite name' do
    component = described_class.new(:name => 'foo on test')
    expect(component[:name]).to eq('foo on test')
    expect(component[:client_id]).to eq('foo')
    expect(component[:realm]).to eq('test')
  end

  it 'should default to client_authenticator_type=client-secret' do
    expect(resource[:client_authenticator_type]).to eq('client-secret')
  end

  it 'should default to protocol=openid-connect' do
    expect(resource[:protocol]).to eq('openid-connect')
  end

  it 'should not allow invalid protocol' do
    config[:protocol] = 'foo'
    expect {
      resource
    }.to raise_error
  end

  defaults = {
    :enabled => :true,
    :direct_access_grants_enabled => :true,
    :public_client => :false,
    :redirect_uris => [],
    :web_origins => [],
  }

  # Test basic properties
  [
    :secret,
    :client_template,
  ].each do |p|
    it "should accept a #{p.to_s}" do
      config[p] = 'foo'
      expect(resource[p]).to eq('foo')
    end
    if defaults[p]
      it "should have default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  # Test boolean properties
  [
    :enabled,
    :direct_access_grants_enabled,
    :public_client,
  ].each do |p|
    it "should accept true for #{p.to_s}" do
      config[p] = true
      expect(resource[p]).to eq(:true)
    end
    it "should accept true for #{p.to_s} string" do
      config[p] = 'true'
      expect(resource[p]).to eq(:true)
    end
    it "should accept false for #{p.to_s}" do
      config[p] = false
      expect(resource[p]).to eq(:false)
    end
    it "should accept false for #{p.to_s} string" do
      config[p] = 'false'
      expect(resource[p]).to eq(:false)
    end
    it "should not accept strings for #{p.to_s}" do
      config[p] = 'foo'
      expect {
        resource
      }.to raise_error
    end
    if defaults[p]
      it "should have default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  # Array properties
  [
    :redirect_uris,
    :web_origins,
  ].each do |p|
    it 'should accept array' do
      config[p] = ['foo','bar']
      expect(resource[p]).to eq(['foo','bar'])
    end
    if defaults[p]
      it "should have default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  it 'should autorequire keycloak_conn_validator' do
    keycloak_conn_validator = Puppet::Type.type(:keycloak_conn_validator).new(:name => 'keycloak')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_conn_validator
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_conn_validator.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'should autorequire kcadm-wrapper.sh' do
    file = Puppet::Type.type(:file).new(:name => 'kcadm-wrapper.sh', :path => '/opt/keycloak/bin/kcadm-wrapper.sh')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource file
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(file.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'should autorequire keycloak_realm' do
    keycloak_realm = Puppet::Type.type(:keycloak_realm).new(:name => 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_realm
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_realm.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'should autorequire keycloak_client_template' do
    config[:client_template] = 'foo'
    keycloak_client_template = Puppet::Type.type(:keycloak_client_template).new(:name => 'foo', :realm => 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_client_template
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_client_template.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'should autorequire client_template protocol mappers' do
    config[:client_template] = 'foo'
    keycloak_protocol_mapper = Puppet::Type.type(:keycloak_protocol_mapper).new(:name => 'bar', :realm => 'test', :client_template => 'foo')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_protocol_mapper
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_protocol_mapper.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

end
