require 'spec_helper'

describe Puppet::Type.type(:keycloak_client) do
  before(:each) do
    @client = described_class.new(:name => 'foo', :realm => 'test')
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource @client 
    }.to_not raise_error
  end

  it 'should have a name' do
    expect(@client[:name]).to eq('foo')
  end

  it 'should have client_id default to name' do
    expect(@client[:client_id]).to eq('foo')
  end

  it 'should have id default to name' do
    expect(@client[:id]).to eq('foo')
  end

  it 'should have realm' do
    expect(@client[:realm]).to eq('test')
  end

  it 'should handle componsite name' do
    component = described_class.new(:name => 'foo on test')
    expect(component[:name]).to eq('foo on test')
    expect(component[:client_id]).to eq('foo')
    expect(component[:realm]).to eq('test')
  end

  it 'should default to client_authenticator_type=client-secret' do
    expect(@client[:client_authenticator_type]).to eq('client-secret')
  end

  # Test basic properties
  [
    :secret,
    :client_template,
  ].each do |p|
    it "should accept a #{p.to_s}" do
      @client[p] = 'foo'
      expect(@client[p]).to eq('foo')
    end
  end

  # Test boolean properties
  [
    :enabled,
  ].each do |p|
    it "should accept true for #{p.to_s}" do
      @client[p] = true
      expect(@client[p]).to eq(:true)
      @client[p] = 'true'
      expect(@client[p]).to eq(:true)
    end
    it "should accept false for #{p.to_s}" do
      @client[p] = false
      expect(@client[p]).to eq(:false)
      @client[p] = 'false'
      expect(@client[p]).to eq(:false)
    end
    it "should not accept strings for #{p.to_s}" do
      expect {
        @client[p] = 'foo'
      }.to raise_error
    end
  end

  # Array properties
  [
    :redirect_uris,
  ].each do |p|
    it 'should accept array' do
      @client[p] = ['foo','bar']
      expect(@client[p]).to eq(['foo','bar'])
    end
  end

  let(:pre_condition) { 'keycloak::client_template { "foo": realm => "test"}' }

  it 'should autorequire keycloak_conn_validator' do
    keycloak_conn_validator = Puppet::Type.type(:keycloak_conn_validator).new(:name => 'keycloak')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @client
    catalog.add_resource keycloak_conn_validator
    rel = @client.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_conn_validator.ref)
    expect(rel.target.ref).to eq(@client.ref)
  end

  it 'should autorequire kcadm-wrapper.sh' do
    file = Puppet::Type.type(:file).new(:name => 'kcadm-wrapper.sh', :path => '/opt/keycloak/bin/kcadm-wrapper.sh')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @client
    catalog.add_resource file
    rel = @client.autorequire[0]
    expect(rel.source.ref).to eq(file.ref)
    expect(rel.target.ref).to eq(@client.ref)
  end

  it 'should autorequire keycloak_realm' do
    keycloak_realm = Puppet::Type.type(:keycloak_realm).new(:name => 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @client
    catalog.add_resource keycloak_realm
    rel = @client.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_realm.ref)
    expect(rel.target.ref).to eq(@client.ref)
  end

end
