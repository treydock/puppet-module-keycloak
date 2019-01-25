require 'spec_helper'

describe Puppet::Type.type(:keycloak_ldap_mapper) do
  let(:default_config) do
    {
      :name => 'foo',
      :realm => 'test',
      :ldap => 'ldap-test',
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

  it 'should not have id default' do
    expect(resource[:id]).to be_nil
  end

  it 'should have realm' do
    expect(resource[:realm]).to eq('test')
  end

  it 'should handle componsite name' do
    component = described_class.new(:name => 'foo for ldap on test')
    expect(component[:name]).to eq('foo for ldap on test')
    expect(component[:resource_name]).to eq('foo')
    expect(component[:ldap]).to eq('ldap')
    expect(component[:realm]).to eq('test')
  end

  it 'should handle componsite name with space' do
    component = described_class.new(:name => 'full name for ldap on test')
    expect(component[:name]).to eq('full name for ldap on test')
    expect(component[:resource_name]).to eq('full name')
    expect(component[:ldap]).to eq('ldap')
    expect(component[:realm]).to eq('test')
  end

  it 'should default to type=user-attribute-ldap-mapper' do
    expect(resource[:type]).to eq('user-attribute-ldap-mapper')
  end

  it 'should allow valid type' do
    config[:type] = 'full-name-ldap-mapper'
    expect(resource[:type]).to eq('full-name-ldap-mapper')
  end

  it 'should not allow invalid type' do
    config[:type] = 'foo'
    expect {
      resource
    }.to raise_error
  end

  it 'should have is_mandatory_in_ldap be nil for full-name-ldap-mapper' do
    config[:type] = 'full-name-ldap-mapper'
    expect(resource[:is_mandatory_in_ldap]).to be_nil
  end

  it 'should have is_mandatory_in_ldap default to false for user-attribute-ldap-mapper' do
    config[:type] = 'user-attribute-ldap-mapper'
    expect(resource[:is_mandatory_in_ldap]).to be(:false)
  end

  it 'should have always_read_value_from_ldap be nil for full-name-ldap-mapper' do
    config[:type] = 'full-name-ldap-mapper'
    expect(resource[:always_read_value_from_ldap]).to be_nil
  end

  it 'should have always_read_value_from_ldap default to true for user-attribute-ldap-mapper' do
    config[:type] = 'user-attribute-ldap-mapper'
    expect(resource[:always_read_value_from_ldap]).to be(:true)
  end

  it 'should accept always_read_value_from_ldap=>false' do
    config[:always_read_value_from_ldap] = false
    expect(resource[:always_read_value_from_ldap]).to eq(:false)
  end

  it 'should have write_only with no default' do
    expect(resource[:write_only]).to be_nil
  end

  it 'should have write_only default to false for full-name-ldap-mapper' do
    config[:type] = 'full-name-ldap-mapper'
    expect(resource[:write_only]).to be(:false)
  end

  defaults = {
    :read_only => :true,
  }

  # Test basic properties
  [
    :ldap,
    :ldap_attribute,
    :user_model_attribute,
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
    :read_only,
    :write_only,
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

  it 'should autorequire keycloak_ldap_user_provider' do
    keycloak_ldap_user_provider = Puppet::Type.type(:keycloak_ldap_user_provider).new(:name => 'ldap', :realm => 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_ldap_user_provider
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_ldap_user_provider.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

end
