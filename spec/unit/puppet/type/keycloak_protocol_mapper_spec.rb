require 'spec_helper'

describe Puppet::Type.type(:keycloak_protocol_mapper) do
  before(:each) do
    @protocol_mapper = described_class.new(:name => 'foo', :realm => 'test', :client_template => 'oidc')
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource @protocol_mapper 
    }.to_not raise_error
  end

  it 'should have a name' do
    expect(@protocol_mapper[:name]).to eq('foo')
  end

  it 'should have resource_name default to name' do
    expect(@protocol_mapper[:resource_name]).to eq('foo')
  end

  it 'should have id default to name-realm' do
    expect(@protocol_mapper[:id]).to eq('b84ed8ed-a7b1-502f-83f6-90132e68adef')
  end

  it 'should have realm' do
    expect(@protocol_mapper[:realm]).to eq('test')
  end

  it 'should handle componsite name' do
    component = described_class.new(:name => 'foo for oidc on test')
    expect(component[:name]).to eq('foo for oidc on test')
    expect(component[:resource_name]).to eq('foo')
    expect(component[:client_template]).to eq('oidc')
    expect(component[:realm]).to eq('test')
  end

  it 'should handle componsite name with space' do
    component = described_class.new(:name => 'full name for oidc on test')
    expect(component[:name]).to eq('full name for oidc on test')
    expect(component[:resource_name]).to eq('full name')
    expect(component[:client_template]).to eq('oidc')
    expect(component[:realm]).to eq('test')
  end

  it 'should default to protocol=openid-connect' do
    expect(@protocol_mapper[:protocol]).to eq('openid-connect')
  end

  it 'should not allow invalid protocol' do
    expect {
      @protocol_mapper[:protocol] = 'foo'
    }.to raise_error
  end

  it 'should default to type=oidc-usermodel-property-mapper' do
    expect(@protocol_mapper[:type]).to eq('oidc-usermodel-property-mapper')
  end

  it 'should allow valid type' do
    @protocol_mapper[:type] = 'oidc-full-name-mapper'
    expect(@protocol_mapper[:type]).to eq('oidc-full-name-mapper')
  end

  it 'should allow valid type' do
    @protocol_mapper[:type] = 'saml-user-property-mapper'
    expect(@protocol_mapper[:type]).to eq('saml-user-property-mapper')
  end

  it 'should not allow invalid type' do
    expect {
      @protocol_mapper[:type] = 'foo'
    }.to raise_error
  end

  # Test basic properties
  [
    :consent_text,
    :claim_name,
  ].each do |p|
    it "should accept a #{p.to_s}" do
      @protocol_mapper[p] = 'foo'
      expect(@protocol_mapper[p]).to eq('foo')
    end
  end

  it 'should have user_attribute be nil for full-name-ldap-mapper' do
    component = described_class.new(:name => 'foo', :realm => 'test', :type => 'oidc-full-name-mapper')
    expect(component[:user_attribute]).to be_nil
  end

  it 'should have user_attribute default to name for oidc-usermodel-property-mapper' do
    component = described_class.new(:name => 'foo', :realm => 'test', :type => 'oidc-usermodel-property-mapper')
    expect(component[:user_attribute]).to eq('foo')
  end

  it 'should have json_type_label be nil for full-name-ldap-mapper' do
    component = described_class.new(:name => 'foo', :realm => 'test', :type => 'oidc-full-name-mapper')
    expect(component[:json_type_label]).to be_nil
  end

  it 'should have json_type_label default to String for oidc-usermodel-property-mapper' do
    component = described_class.new(:name => 'foo', :realm => 'test', :type => 'oidc-usermodel-property-mapper')
    expect(component[:json_type_label]).to eq('String')
  end

  it 'should have friendly_name as nil' do
    expect(@protocol_mapper[:friendly_name]).to be_nil
  end

  it 'should allow valid friendly_name' do
    @protocol_mapper[:type] = 'saml-user-property-mapper'
    @protocol_mapper[:friendly_name] = 'email'
    expect(@protocol_mapper[:friendly_name]).to eq('email')
  end

  it 'should have attribute_name as nil' do
    expect(@protocol_mapper[:attribute_name]).to be_nil
  end

  it 'should allow valid attribute_name' do
    @protocol_mapper[:type] = 'saml-user-property-mapper'
    @protocol_mapper[:attribute_name] = 'email'
    expect(@protocol_mapper[:attribute_name]).to eq('email')
  end

  # Test boolean properties
  [
    :consent_required,
    :id_token_claim,
    :access_token_claim,
    :userinfo_token_claim,
  ].each do |p|
    it "should accept true for #{p.to_s}" do
      @protocol_mapper[p] = true
      expect(@protocol_mapper[p]).to eq(:true)
      @protocol_mapper[p] = 'true'
      expect(@protocol_mapper[p]).to eq(:true)
    end
    it "should accept false for #{p.to_s}" do
      @protocol_mapper[p] = false
      expect(@protocol_mapper[p]).to eq(:false)
      @protocol_mapper[p] = 'false'
      expect(@protocol_mapper[p]).to eq(:false)
    end
    it "should not accept strings for #{p.to_s}" do
      expect {
        @protocol_mapper[p] = 'foo'
      }.to raise_error
    end
  end

  it 'should accept value for attribute_nameformat' do
    @protocol_mapper[:attribute_nameformat] = 'Basic'
    expect(@protocol_mapper[:attribute_nameformat]).to eq(:basic)
    @protocol_mapper[:attribute_nameformat] = 'uri'
    expect(@protocol_mapper[:attribute_nameformat]).to eq(:uri)
  end

  it 'should not accept invalid value for attribute_nameformat' do
    expect {
      @protocol_mapper[:attribute_nameformat] = 'foo'
    }.to raise_error
  end

  it 'should accept value for single' do
    @protocol_mapper[:single] = false
    expect(@protocol_mapper[:single]).to eq(:false)
    @protocol_mapper[:single] = 'false'
    expect(@protocol_mapper[:single]).to eq(:false)
  end

  it 'should not accept invalid value for single' do
    expect {
      @protocol_mapper[:single] = 'foo'
    }.to raise_error
  end

  it 'should autorequire keycloak_conn_validator' do
    keycloak_conn_validator = Puppet::Type.type(:keycloak_conn_validator).new(:name => 'keycloak')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @protocol_mapper
    catalog.add_resource keycloak_conn_validator
    rel = @protocol_mapper.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_conn_validator.ref)
    expect(rel.target.ref).to eq(@protocol_mapper.ref)
  end

  it 'should autorequire kcadm-wrapper.sh' do
    file = Puppet::Type.type(:file).new(:name => 'kcadm-wrapper.sh', :path => '/opt/keycloak/bin/kcadm-wrapper.sh')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @protocol_mapper
    catalog.add_resource file
    rel = @protocol_mapper.autorequire[0]
    expect(rel.source.ref).to eq(file.ref)
    expect(rel.target.ref).to eq(@protocol_mapper.ref)
  end

  it 'should autorequire keycloak_realm' do
    keycloak_realm = Puppet::Type.type(:keycloak_realm).new(:name => 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @protocol_mapper
    catalog.add_resource keycloak_realm
    rel = @protocol_mapper.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_realm.ref)
    expect(rel.target.ref).to eq(@protocol_mapper.ref)
  end

  it 'should autorequire keycloak_client_template' do
    keycloak_client_template = Puppet::Type.type(:keycloak_client_template).new(:name => 'oidc', :realm => 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource @protocol_mapper
    catalog.add_resource keycloak_client_template
    rel = @protocol_mapper.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_client_template.ref)
    expect(rel.target.ref).to eq(@protocol_mapper.ref)
  end

end
