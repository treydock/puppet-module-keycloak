require 'spec_helper'

describe Puppet::Type.type(:keycloak_flow) do
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
    expect(resource[:alias]).to eq('foo')
  end

  it 'has id default to name' do
    expect(resource[:id]).to eq('foo-test')
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

  it 'defaults to provider_id=basic-flow' do
    expect(resource[:provider_id]).to eq('basic-flow')
  end

  it 'does not allow invalid provider_id' do
    config[:provider_id] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  defaults = {}

  describe 'basic properties' do
    # Test basic properties
    [
      :description,
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

  it 'requires realm' do
    config.delete(:realm)
    expect { resource }.to raise_error(%r{must have a realm defined})
  end
end
