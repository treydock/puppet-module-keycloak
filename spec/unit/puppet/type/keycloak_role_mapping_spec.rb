# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:keycloak_role_mapping) do
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

  defaults = {
    group: :false,
  }

  describe 'basic properties' do
    # Test basic properties
    [
      :realm,
      :name,
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

  describe 'boolean properties' do
    # Test boolean properties
    [
      :group,
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
      :realm_roles,
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
end
