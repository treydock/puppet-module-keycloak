require 'spec_helper'

describe Puppet::Type.type(:keycloak_ldap_user_provider) do
  before(:each) do
    @component = described_class.new(:name => 'foo', :realm => 'test')
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
    expect(@component[:id]).to eq('foo-test')
  end

  it 'should have realm' do
    expect(@component[:realm]).to eq('test')
  end

  it 'should handle componsite name' do
    component = described_class.new(:name => 'foo on test')
    expect(component[:name]).to eq('foo on test')
    expect(component[:resource_name]).to eq('foo')
    expect(component[:realm]).to eq('test')
  end

  it 'should default to auth_type=none' do
    expect(@component[:auth_type]).to eq('none')
  end

  it 'should not allow invalid auth_type' do
    expect {
      @component[:auth_type] = 'foo'
    }.to raise_error
  end

  it 'should default to edit_mode=READ_ONLY' do
    expect(@component[:edit_mode]).to eq('READ_ONLY')
  end

  it 'should not allow invalid edit_mode' do
    expect {
      @component[:edit_mode] = 'foo'
    }.to raise_error
  end

  it 'should default to vendor=other' do
    expect(@component[:vendor]).to eq('other')
  end

  it 'should not allow invalid vendor' do
    expect {
      @component[:vendor] = 'foo'
    }.to raise_error
  end

  it 'should default to use_truststore_spi=ldapsOnly' do
    expect(@component[:use_truststore_spi]).to eq('ldapsOnly')
  end

  it 'should not allow invalid use_truststore_spi' do
    expect {
      @component[:use_truststore_spi] = 'foo'
    }.to raise_error
  end

  # Test basic properties
  [
    :users_dn,
    :connection_url,
    :priority,
    :batch_size_for_sync,
    :user_object_classes,
    :username_ldap_attribute,
    :rdn_ldap_attribute,
    :uuid_ldap_attribute,
  ].each do |p|
    it "should accept a #{p.to_s}" do
      @component[p] = 'foo'
      expect(@component[p]).to eq('foo')
    end
  end

  # Test boolean properties
  [
    :import_enabled,
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

end
