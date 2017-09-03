require 'spec_helper'

describe Puppet::Type.type(:keycloak_ldap_mapper) do
  before(:each) do
    @component = described_class.new(:name => 'foo', :realm => 'test', :ldap => 'ldap-test')
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource @component 
    }.to_not raise_error
  end

  it 'should have a name' do
    expect(@component[:name]).to eq('foo')
  end

  it 'should have resource_name default to name' do
    expect(@component[:resource_name]).to eq('foo')
  end

  it 'should have id default to name-realm' do
    expect(@component[:id]).to eq('b84ed8ed-a7b1-502f-83f6-90132e68adef')
  end

  it 'should have realm' do
    expect(@component[:realm]).to eq('test')
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
    expect(@component[:type]).to eq('user-attribute-ldap-mapper')
  end

  it 'should allow valid type' do
    @component[:type] = 'full-name-ldap-mapper'
    expect(@component[:type]).to eq('full-name-ldap-mapper')
  end

  it 'should not allow invalid type' do
    expect {
      @component[:type] = 'foo'
    }.to raise_error
  end

  # Test basic properties
  [
    :ldap,
    :ldap_attribute,
    :user_model_attribute,
  ].each do |p|
    it "should accept a #{p.to_s}" do
      @component[p] = 'foo'
      expect(@component[p]).to eq('foo')
    end
  end

  it 'should have is_mandatory_in_ldap be nil for full-name-ldap-mapper' do
    component = described_class.new(:name => 'foo', :realm => 'test', :type => 'full-name-ldap-mapper')
    expect(component[:is_mandatory_in_ldap]).to be_nil
  end

  it 'should have is_mandatory_in_ldap default to false for user-attribute-ldap-mapper' do
    component = described_class.new(:name => 'foo', :realm => 'test', :type => 'user-attribute-ldap-mapper')
    expect(component[:is_mandatory_in_ldap]).to be(:false)
  end

  # Test boolean properties
  [
    :read_only,
    :write_only,
  ].each do |p|
    it "should accept true for #{p.to_s}" do
      @component[p] = true
      expect(@component[p]).to eq(:true)
      @component[p] = 'true'
      expect(@component[p]).to eq(:true)
    end
    it "should accept false for #{p.to_s}" do
      @component[p] = false
      expect(@component[p]).to eq(:false)
      @component[p] = 'false'
      expect(@component[p]).to eq(:false)
    end
    it "should not accept strings for #{p.to_s}" do
      expect {
        @component[p] = 'foo'
      }.to raise_error
    end
  end

  it 'should autorequire keycloak_conn_validator' do
    keycloak_conn_validator = Puppet::Type.type(:keycloak_conn_validator).new(:name => 'keycloak')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @component
    catalog.add_resource keycloak_conn_validator
    rel = @component.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_conn_validator.ref)
    expect(rel.target.ref).to eq(@component.ref)
  end

  it 'should autorequire kcadm-wrapper.sh' do
    file = Puppet::Type.type(:file).new(:name => 'kcadm-wrapper.sh', :path => '/opt/keycloak/bin/kcadm-wrapper.sh')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @component
    catalog.add_resource file
    rel = @component.autorequire[0]
    expect(rel.source.ref).to eq(file.ref)
    expect(rel.target.ref).to eq(@component.ref)
  end

  it 'should autorequire keycloak_realm' do
    keycloak_realm = Puppet::Type.type(:keycloak_realm).new(:name => 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @component
    catalog.add_resource keycloak_realm
    rel = @component.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_realm.ref)
    expect(rel.target.ref).to eq(@component.ref)
  end

  it 'should autorequire keycloak_ldap_user_provider' do
    keycloak_ldap_user_provider = Puppet::Type.type(:keycloak_ldap_user_provider).new(:name => 'ldap', :realm => 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @component
    catalog.add_resource keycloak_ldap_user_provider
    rel = @component.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_ldap_user_provider.ref)
    expect(rel.target.ref).to eq(@component.ref)
  end

end
