require 'spec_helper'

describe Puppet::Type.type(:keycloak_realm) do
  before(:each) do
    @realm = described_class.new(:name => 'test')
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource @realm 
    }.to_not raise_error
  end

  it 'should have a name' do
    expect(@realm[:name]).to eq('test')
  end

  it 'should have id default to name' do
    expect(@realm[:id]).to eq('test')
  end

  # Test basic properties
  [
    :display_name,
    :display_name_html,
    :login_theme,
    :account_theme,
    :admin_theme,
    :email_theme,
  ].each do |p|
    it "should accept a #{p.to_s}" do
      @realm[p] = 'foo'
      expect(@realm[p]).to eq('foo')
    end
  end

  # Test boolean properties
  [
    :remember_me,
    :login_with_email_allowed,
  ].each do |p|
    it "should accept true for #{p.to_s}" do
      @realm[p] = true
      expect(@realm[p]).to eq(:true)
      @realm[p] = 'true'
      expect(@realm[p]).to eq(:true)
    end
    it "should accept false for #{p.to_s}" do
      @realm[p] = false
      expect(@realm[p]).to eq(:false)
      @realm[p] = 'false'
      expect(@realm[p]).to eq(:false)
    end
    it "should not accept strings for #{p.to_s}" do
      expect {
        @realm[p] = 'foo'
      }.to raise_error
    end
  end

  it 'should autorequire keycloak_conn_validator' do
    keycloak_conn_validator = Puppet::Type.type(:keycloak_conn_validator).new(:name => 'keycloak')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @realm
    catalog.add_resource keycloak_conn_validator
    rel = @realm.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_conn_validator.ref)
    expect(rel.target.ref).to eq(@realm.ref)
  end

  it 'should autorequire kcadm-wrapper.sh' do
    file = Puppet::Type.type(:file).new(:name => 'kcadm-wrapper.sh', :path => '/opt/keycloak/bin/kcadm-wrapper.sh')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @realm
    catalog.add_resource file
    rel = @realm.autorequire[0]
    expect(rel.source.ref).to eq(file.ref)
    expect(rel.target.ref).to eq(@realm.ref)
  end

end
