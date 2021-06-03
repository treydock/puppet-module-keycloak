require 'spec_helper'

describe Puppet::Type.type(:keycloak_flow_execution) do
  let(:default_config) do
    {
      name: 'foo',
      realm: 'test',
      index: 0,
      flow_alias: 'bar',
      provider_id: 'auth-username-password-form',
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

  it 'has realm' do
    expect(resource[:realm]).to eq('test')
  end

  it 'handles componsite name' do
    component = described_class.new(name: 'foo under bar on test')
    expect(component[:name]).to eq('foo under bar on test')
    expect(component[:provider_id]).to eq('foo')
    expect(component[:flow_alias]).to eq('bar')
    expect(component[:realm]).to eq('test')
  end

  defaults = {}

  describe 'basic properties' do
    # Test basic properties
    [
      :display_name,
      :alias,
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
      :configurable,
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

  describe 'integer properties' do
    # Integer properties
    [
      :index,
    ].each do |p|
      it "should accept integer for #{p}" do
        config[p] = 1
        expect(resource[p]).to eq(1)
      end
      it "should accept integer string for #{p}" do
        config[p] = '1'
        expect(resource[p]).to eq(1)
      end
      it "should not accept non-integer for #{p}" do
        config[p] = 'foo'
        expect { resource }.to raise_error(%r{Integer})
      end
      next unless defaults[p]
      it "should have default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'requirement' do
    it 'defaults to DISABLED for top_level=false' do
      expect(resource[:requirement]).to eq('DISABLED')
    end
    [
      'DISABLED', 'ALTERNATIVE', 'REQUIRED', 'CONDITIONAL'
    ].each do |v|
      it "accepts value #{v}" do
        config[:requirement] = v
        expect(resource[:requirement]).to eq(v)
      end
      it "accepts lowercase value #{v}" do
        config[:requirement] = v.downcase
        expect(resource[:requirement]).to eq(v)
      end
    end
    it 'does not accept invalid value' do
      config[:requirement] = 'foo'
      expect { resource }.to raise_error(%r{foo})
    end
  end

  describe 'config' do
    it 'accepts hash' do
      config[:config] = { 'foo' => 'bar' }
      expect(resource[:config]).to eq('foo' => 'bar')
    end
    it 'requires hash' do
      config[:config] = 'foo'
      expect { resource }.to raise_error(%r{must be a Hash})
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

  it 'autorequires keycloak_flow of parent flow' do
    keycloak_flow = Puppet::Type.type(:keycloak_flow).new(name: 'bar on test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_flow
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_flow.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires keycloak_flow of lower index' do
    config[:index] = 1
    keycloak_flow = Puppet::Type.type(:keycloak_flow).new(name: 'baz under bar on test', index: 0)
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_flow
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_flow.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires keycloak_flow_execution of lower index' do
    config[:index] = 1
    keycloak_flow_execution = Puppet::Type.type(:keycloak_flow_execution).new(name: 'baz under bar on test', index: 0)
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_flow_execution
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_flow_execution.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires keycloak_resource_validator' do
    keycloak_resource_validator = Puppet::Type.type(:keycloak_resource_validator).new(
      name: 'duo-spi',
      test_url: 'foo',
      test_key: 'bar',
      test_value: 'baz',
      dependent_resources: ['Keycloak_flow_execution[foo]'],
    )
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_resource_validator
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_resource_validator.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  describe 'validations' do
    it 'requires realm' do
      config.delete(:realm)
      expect { resource }.to raise_error(%r{must have a realm defined})
    end
    it 'requires index when present' do
      config.delete(:index)
      config[:ensure] = 'present'
      expect { resource }.to raise_error(%r{index is required})
    end
    it 'does not require index for absent' do
      config.delete(:index)
      config[:ensure] = 'absent'
      expect { resource }.not_to raise_error
    end
    it 'requires flow_alias' do
      config.delete(:flow_alias)
      config[:ensure] = 'present'
      expect { resource }.to raise_error(%r{flow_alias is required})
    end
    it 'requires provider_id' do
      config.delete(:provider_id)
      config[:ensure] = 'present'
      expect { resource }.to raise_error(%r{provider_id is required})
    end
  end
end
