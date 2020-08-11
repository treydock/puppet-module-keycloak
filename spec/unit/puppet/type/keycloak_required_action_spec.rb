require 'spec_helper'

describe Puppet::Type.type(:keycloak_required_action) do
  let(:default_config) do
    {
      name: 'foo',
      realm: 'test',
      alias: 'something',
      provider_id: 'some-provider',
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

  it 'has alias default to provider_id' do
    config.delete(:alias)
    expect(resource[:alias]).to eq('some-provider')
  end

  it 'handles componsite name' do
    component = described_class.new(name: 'foo on test', provider_id: 'provider')
    expect(component[:name]).to eq('foo on test')
    expect(component[:alias]).to eq('foo')
    expect(component[:realm]).to eq('test')
  end

  defaults = {
    enabled: true,
    default: false,
  }

  describe 'basic properties' do
    # Test basic properties
    [
      :realm,
      :name,
      :display_name,
      :provider_id,
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
      :enabled,
      :default,
    ].each do |p|
      it "should accept true for #{p}" do
        config[p] = true
        expect(resource[p]).to eq(true)
      end
      it "should accept true for #{p} string" do
        config[p] = 'true'
        expect(resource[p]).to eq(true)
      end
      it "should accept false for #{p}" do
        config[p] = false
        expect(resource[p]).to eq(false)
      end
      it "should accept false for #{p} string" do
        config[p] = 'false'
        expect(resource[p]).to eq(false)
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

  describe 'hash properties' do
    # Hash properties
    [
      :config,
    ].each do |p|
      it "should accept hash for #{p}" do
        config[p] = { foo: 'bar' }
        expect(resource[p]).to eq(foo: 'bar')
      end
      it 'requires hash' do
        config[p] = 'foo'
        expect { resource }.to raise_error(%r{must be a Hash})
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
      :priority,
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

  describe 'validations' do
    it 'requires realm' do
      config.delete(:realm)
      expect { resource }.to raise_error(%r{must have a realm defined})
    end
    it 'requires alias' do
      config.delete(:provider_id)
      config.delete(:alias)
      expect { resource }.to raise_error(%r{must have a alias defined})
    end
    it 'requires provider_id when present' do
      config.delete(:provider_id)
      config[:ensure] = 'present'
      expect { resource }.to raise_error(%r{provider_id is required})
    end
    it 'does not require provider_id for absent' do
      config.delete(:provider_id)
      config[:ensure] = 'absent'
      expect { resource }.not_to raise_error
    end
  end
end
