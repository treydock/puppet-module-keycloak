require 'spec_helper'

describe Puppet::Type.type(:keycloak_protocol_mapper) do
  let(:default_config) do
    {
      :name => 'foo',
      :realm => 'test',
      :client_scope => 'oidc',
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
    component = described_class.new(:name => 'foo for oidc on test')
    expect(component[:name]).to eq('foo for oidc on test')
    expect(component[:resource_name]).to eq('foo')
    expect(component[:client_scope]).to eq('oidc')
    expect(component[:realm]).to eq('test')
  end

  it 'should handle componsite name with space' do
    component = described_class.new(:name => 'full name for oidc on test')
    expect(component[:name]).to eq('full name for oidc on test')
    expect(component[:resource_name]).to eq('full name')
    expect(component[:client_scope]).to eq('oidc')
    expect(component[:realm]).to eq('test')
  end

  it 'should default to protocol=openid-connect' do
    expect(resource[:protocol]).to eq('openid-connect')
  end

  it 'should not allow invalid protocol' do
    config[:protocol] = 'foo'
    expect {
      resource
    }.to raise_error
  end

  it 'should default to type=oidc-usermodel-property-mapper' do
    expect(resource[:type]).to eq('oidc-usermodel-property-mapper')
  end

  it 'should allow valid type' do
    config[:type] = 'oidc-full-name-mapper'
    expect(resource[:type]).to eq('oidc-full-name-mapper')
  end

  it 'should allow valid type' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    expect(resource[:type]).to eq('saml-user-property-mapper')
  end

  it 'should not allow invalid type' do
    config[:type] = 'foo'
    expect {
      resource
    }.to raise_error
  end

  it 'should have user_attribute be nil for full-name-ldap-mapper' do
    config[:type] = 'oidc-full-name-mapper'
    expect(resource[:user_attribute]).to be_nil
  end

  it 'should have user_attribute default to name for oidc-usermodel-property-mapper' do
    config[:type] = 'oidc-usermodel-property-mapper'
    expect(resource[:user_attribute]).to eq('foo')
  end

  it 'should have user_attribute default to name for saml-user-property-mapper' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    expect(resource[:user_attribute]).to eq('foo')
  end

  it 'should have json_type_label be nil for full-name-ldap-mapper' do
    config[:type] = 'oidc-full-name-mapper'
    expect(resource[:json_type_label]).to be_nil
  end

  it 'should have json_type_label default to String for oidc-usermodel-property-mapper' do
    config[:type] = 'oidc-usermodel-property-mapper'
    expect(resource[:json_type_label]).to eq('String')
  end

  it 'should have friendly_name as nil' do
    expect(resource[:friendly_name]).to be_nil
  end

  it 'should default friend_name for saml' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    expect(resource[:friendly_name]).to eq('foo')
  end

  it 'should allow valid friendly_name' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    config[:friendly_name] = 'email'
    expect(resource[:friendly_name]).to eq('email')
  end

  it 'should have attribute_name as nil' do
    expect(resource[:attribute_name]).to be_nil
  end

  it 'should default attribute_name for saml' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    expect(resource[:attribute_name]).to eq('foo')
  end

  it 'should allow valid attribute_name' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    config[:attribute_name] = 'email'
    expect(resource[:attribute_name]).to eq('email')
  end

  it 'should default for id_token_claim' do
    expect(resource[:id_token_claim]).to eq(:true)
  end

  it 'should not default id_token_claim for saml' do
    config[:protocol] = 'saml'
    expect(resource[:id_token_claim]).to be_nil
  end

  it 'should accept true for id_token_claim' do
    config[:id_token_claim] = true
    expect(resource[:id_token_claim]).to eq(:true)
  end

  it 'should accept true for id_token_claim as string' do
    config[:id_token_claim] = 'true'
    expect(resource[:id_token_claim]).to eq(:true)
  end

  it 'should accept false for id_token_claim' do
    config[:id_token_claim] = false
    expect(resource[:id_token_claim]).to eq(:false)
  end

  it 'should accept false for id_token_claim as string' do
    config[:id_token_claim] = 'false'
    expect(resource[:id_token_claim]).to eq(:false)
  end

  it "should not accept strings for id_token_claim" do
    config[:id_token_claim] = 'foo'
    expect {
      resource
    }.to raise_error
  end

  it 'should default for access_token_claim' do
    expect(resource[:access_token_claim]).to eq(:true)
  end

  it 'should not default access_token_claim for saml' do
    config[:protocol] = 'saml'
    expect(resource[:access_token_claim]).to be_nil
  end

  it 'should accept true for access_token_claim' do
    config[:access_token_claim] = true
    expect(resource[:access_token_claim]).to eq(:true)
    config[:access_token_claim] = 'true'
    expect(resource[:access_token_claim]).to eq(:true)
  end

  it 'should accept false for access_token_claim' do
    config[:access_token_claim] = false
    expect(resource[:access_token_claim]).to eq(:false)
    config[:access_token_claim] = 'false'
    expect(resource[:access_token_claim]).to eq(:false)
  end

  it "should not accept strings for access_token_claim" do
    config[:access_token_claim] = 'foo'
    expect {
      resource
    }.to raise_error
  end

  it 'should default for userinfo_token_claim' do
    expect(resource[:userinfo_token_claim]).to eq(:true)
  end

  it 'should not default userinfo_token_claim for saml' do
    config[:protocol] = 'saml'
    expect(resource[:userinfo_token_claim]).to be_nil
  end

  it 'should accept true for userinfo_token_claim' do
    config[:userinfo_token_claim] = true
    expect(resource[:userinfo_token_claim]).to eq(:true)
  end

  it 'should accept true for userinfo_token_claim as string' do
    config[:userinfo_token_claim] = 'true'
    expect(resource[:userinfo_token_claim]).to eq(:true)
  end

  it 'should accept false for userinfo_token_claim' do
    config[:userinfo_token_claim] = false
    expect(resource[:userinfo_token_claim]).to eq(:false)
  end

  it 'should accept false for userinfo_token_claim as string' do
    config[:userinfo_token_claim] = 'false'
    expect(resource[:userinfo_token_claim]).to eq(:false)
  end

  it "should not accept strings for userinfo_token_claim" do
    config[:userinfo_token_claim] = 'foo'
    expect {
      resource
    }.to raise_error
  end

  defaults = {}

  # Test basic properties
  [
    :claim_name,
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
  ].each do |p|
    it "should accept true for #{p.to_s}" do
      config[p] = true
      expect(resource[p]).to eq(:true)
    end
    it "should accept true for #{p.to_s} as string" do
      config[p] = 'true'
      expect(resource[p]).to eq(:true)
    end
    it "should accept false for #{p.to_s}" do
      config[p] = false
      expect(resource[p]).to eq(:false)
    end
    it "should accept false for #{p.to_s} as string" do
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

  it 'should accept value for attribute_nameformat' do
    config[:protocol] = 'saml'
    config[:attribute_nameformat] = 'Basic'
    expect(resource[:attribute_nameformat]).to eq(:basic)
  end

  it 'should accept value for attribute_nameformat' do
    config[:protocol] = 'saml'
    config[:attribute_nameformat] = 'uri'
    expect(resource[:attribute_nameformat]).to eq(:uri)
  end

  it 'should not accept invalid value for attribute_nameformat' do
    config[:protocol] = 'saml'
    config[:attribute_nameformat] = 'foo'
    expect {
      resource
    }.to raise_error
  end

  it 'should accept value for single' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-role-list-mapper'
    config[:single] = false
    expect(resource[:single]).to eq(:false)
  end

  it 'should accept value for single string' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-role-list-mapper'
    config[:single] = 'false'
    expect(resource[:single]).to eq(:false)
  end

  it 'should have default for single' do
    expect(resource[:single]).to be_nil
  end

  it 'should have default for single and saml-role-list-mapper' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-role-list-mapper'
    expect(resource[:single]).to eq(:false)
  end

  it 'should not accept invalid value for single' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-role-list-mapper'
    config[:single] = 'foo'
    expect {
      resource
    }.to raise_error
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

  it 'should autorequire keycloak_client_scope' do
    keycloak_client_scope = Puppet::Type.type(:keycloak_client_scope).new(:name => 'oidc', :realm => 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_client_scope
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_client_scope.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

end
