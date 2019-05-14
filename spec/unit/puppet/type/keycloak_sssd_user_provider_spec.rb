require 'spec_helper'

describe Puppet::Type.type(:keycloak_sssd_user_provider) do
  let(:default_config) do
    {
      :name => 'foo',
      :realm => 'test'
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

  it 'should have resource_name default to name' do
    expect(resource[:resource_name]).to eq('foo')
  end

  it 'should have id default to resource_name-realm' do
    expect(resource[:id]).to eq('foo-test')
  end

  it 'should have realm' do
    expect(resource[:realm]).to eq('test')
  end

  it 'should handle componsite name' do
    component = described_class.new(:name => 'foo on test')
    expect(component[:name]).to eq('foo on test')
    expect(component[:resource_name]).to eq('foo')
    expect(component[:realm]).to eq('test')
  end

  it 'should default to cache_policy=DEFAULT' do
    expect(resource[:cache_policy]).to eq(:DEFAULT)
  end

  it 'should not allow invalid cache_policy' do
    config[:cache_policy] = 'foo'
    expect {
      resource
    }.to raise_error(/foo/)
  end

  defaults = {
    :enabled => :true,
    :priority => '0',
  }

  # Test basic properties
  [
    :priority,
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
  ].each do |p|
    it "should accept true for #{p.to_s}" do
      config[p] = true
      expect(resource[p]).to eq(:true)
      config[p] = 'true'
      expect(resource[p]).to eq(:true)
    end
    it "should accept false for #{p.to_s}" do
      config[p] = false
      expect(resource[p]).to eq(:false)
      config[p] = 'false'
      expect(resource[p]).to eq(:false)
    end
    it "should not accept strings for #{p.to_s}" do
      config[p] = 'foo'
      expect {
        resource
      }.to raise_error(/foo/)
    end
    if defaults[p]
      it "should have default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  # Array properties
  [
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

  it 'should require eviction_hour with cache_policy=EVICT_DAILY' do
    config[:cache_policy] = 'EVICT_DAILY'
    config[:eviction_minute] = '01'
    expect { resource }.to raise_error(Puppet::Error, /cache_policy EVICT_DAILY and EVICT_WEEKLY require eviction_hour/)
  end

  it 'should require eviction_hour with cache_policy=EVICT_WEEKLY' do
    config[:cache_policy] = 'EVICT_WEEKLY'
    config[:eviction_minute] = '01'
    expect { resource }.to raise_error(Puppet::Error, /cache_policy EVICT_DAILY and EVICT_WEEKLY require eviction_hour/)
  end

  it 'should require eviction_minute with cache_policy=EVICT_DAILY' do
    config[:cache_policy] = 'EVICT_DAILY'
    config[:eviction_hour] = '01'
    expect { resource }.to raise_error(Puppet::Error, /cache_policy EVICT_DAILY and EVICT_WEEKLY require eviction_minute/)
  end

  it 'should require eviction_minute with cache_policy=EVICT_WEEKLY' do
    config[:cache_policy] = 'EVICT_WEEKLY'
    config[:eviction_hour] = '01'
    expect { resource }.to raise_error(Puppet::Error, /cache_policy EVICT_DAILY and EVICT_WEEKLY require eviction_minute/)
  end

  it 'should not allow eviction_hour with cache_policy=DEFAULT' do
    config[:eviction_hour] = '01'
    expect { resource }.to raise_error(Puppet::Error, /eviction_hour is only valid for cache_policy EVICT_DAILY and EVICT_WEEKLY/)
  end

  it 'should not allow eviction_minute with cache_policy=DEFAULT' do
    config[:eviction_minute] = '01'
    expect { resource }.to raise_error(Puppet::Error, /eviction_minute is only valid for cache_policy EVICT_DAILY and EVICT_WEEKLY/)
  end

  it 'should require eviction_day with cache_policy=EVICT_WEEKLY' do
    config[:cache_policy] = 'EVICT_WEEKLY'
    config[:eviction_hour] = '01'
    config[:eviction_minute] = '01'
    expect { resource }.to raise_error(Puppet::Error, /cache_policy EVICT_WEEKLY requires eviction_hour/)
  end

  it 'should not allow eviction_day with cache_policy=DEFAULT' do
    config[:eviction_day] = '1'
    expect { resource }.to raise_error(Puppet::Error, /eviction_day is only valid with cache_policy EVICT_WEEKLY/)
  end

  it 'should require max_lifespan with cache_policy=MAX_LIFESPAN' do
    config[:cache_policy] = 'MAX_LIFESPAN'
    expect { resource }.to raise_error(Puppet::Error, /cache_policy MAX_LIFESPAN requires max_lifespan/)
  end

  it 'should not allow max_lifespan with cache_policy=DEFAULT' do
    config[:max_lifespan] = '1'
    expect { resource }.to raise_error(Puppet::Error, /max_lifespan is only valid with cache_policy MAX_LIFESPAN/)
  end
end
