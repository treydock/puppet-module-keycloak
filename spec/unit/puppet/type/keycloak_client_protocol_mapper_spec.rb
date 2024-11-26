# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:keycloak_client_protocol_mapper) do
  let(:default_config) do
    {
      name: 'foo',
      realm: 'test',
      client: 'test.example.com'
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
    expect(resource[:name]).to eq('foo')
  end

  it 'has resource_name default to name' do
    expect(resource[:resource_name]).to eq('foo')
  end

  it 'does not have id default' do
    expect(resource[:id]).to be_nil
  end

  it 'has realm' do
    expect(resource[:realm]).to eq('test')
  end

  it 'handles componsite name' do
    component = described_class.new(name: 'foo for test.example.com on test')
    expect(component[:name]).to eq('foo for test.example.com on test')
    expect(component[:resource_name]).to eq('foo')
    expect(component[:client]).to eq('test.example.com')
    expect(component[:realm]).to eq('test')
  end

  it 'handles componsite name with space' do
    component = described_class.new(name: 'full name for test.example.com on test')
    expect(component[:name]).to eq('full name for test.example.com on test')
    expect(component[:resource_name]).to eq('full name')
    expect(component[:client]).to eq('test.example.com')
    expect(component[:realm]).to eq('test')
  end

  it 'defaults to protocol=openid-connect' do
    expect(resource[:protocol]).to eq('openid-connect')
  end

  it 'does not allow invalid protocol' do
    config[:protocol] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'defaults to type=oidc-usermodel-property-mapper' do
    expect(resource[:type]).to eq('oidc-usermodel-property-mapper')
  end

  it 'allows valid type' do
    config[:type] = 'oidc-full-name-mapper'
    expect(resource[:type]).to eq('oidc-full-name-mapper')
  end

  it 'allows valid saml type' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    expect(resource[:type]).to eq('saml-user-property-mapper')
  end

  it 'does not allow invalid type' do
    config[:type] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'has user_attribute be nil for full-name-ldap-mapper' do
    config[:type] = 'oidc-full-name-mapper'
    expect(resource[:user_attribute]).to be_nil
  end

  it 'has user_attribute default to name for oidc-usermodel-property-mapper' do
    config[:type] = 'oidc-usermodel-property-mapper'
    expect(resource[:user_attribute]).to eq('foo')
  end

  it 'has user_attribute default to name for saml-user-property-mapper' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    expect(resource[:user_attribute]).to eq('foo')
  end

  it 'has json_type_label be nil for full-name-ldap-mapper' do
    config[:type] = 'oidc-full-name-mapper'
    expect(resource[:json_type_label]).to be_nil
  end

  it 'has json_type_label default to String for oidc-usermodel-property-mapper' do
    config[:type] = 'oidc-usermodel-property-mapper'
    expect(resource[:json_type_label]).to eq('String')
  end

  it 'has friendly_name as nil' do
    expect(resource[:friendly_name]).to be_nil
  end

  it 'defaults friend_name for saml' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    expect(resource[:friendly_name]).to eq('foo')
  end

  it 'allows valid friendly_name' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    config[:friendly_name] = 'email'
    expect(resource[:friendly_name]).to eq('email')
  end

  it 'has attribute_name as nil' do
    expect(resource[:attribute_name]).to be_nil
  end

  it 'defaults attribute_name for saml' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    expect(resource[:attribute_name]).to eq('foo')
  end

  it 'allows valid attribute_name' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-user-property-mapper'
    config[:attribute_name] = 'email'
    expect(resource[:attribute_name]).to eq('email')
  end

  it 'defaults for id_token_claim' do
    expect(resource[:id_token_claim]).to eq(:true)
  end

  it 'does not default id_token_claim for saml' do
    config[:protocol] = 'saml'
    expect(resource[:id_token_claim]).to be_nil
  end

  it 'accepts true for id_token_claim' do
    config[:id_token_claim] = true
    expect(resource[:id_token_claim]).to eq(:true)
  end

  it 'accepts true for id_token_claim as string' do
    config[:id_token_claim] = 'true'
    expect(resource[:id_token_claim]).to eq(:true)
  end

  it 'accepts false for id_token_claim' do
    config[:id_token_claim] = false
    expect(resource[:id_token_claim]).to eq(:false)
  end

  it 'accepts false for id_token_claim as string' do
    config[:id_token_claim] = 'false'
    expect(resource[:id_token_claim]).to eq(:false)
  end

  it 'does not accept strings for id_token_claim' do
    config[:id_token_claim] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'defaults for access_token_claim' do
    expect(resource[:access_token_claim]).to eq(:true)
  end

  it 'does not default access_token_claim for saml' do
    config[:protocol] = 'saml'
    expect(resource[:access_token_claim]).to be_nil
  end

  it 'accepts true for access_token_claim' do
    config[:access_token_claim] = true
    expect(resource[:access_token_claim]).to eq(:true)
    config[:access_token_claim] = 'true'
    expect(resource[:access_token_claim]).to eq(:true)
  end

  it 'accepts false for access_token_claim' do
    config[:access_token_claim] = false
    expect(resource[:access_token_claim]).to eq(:false)
    config[:access_token_claim] = 'false'
    expect(resource[:access_token_claim]).to eq(:false)
  end

  it 'does not accept strings for access_token_claim' do
    config[:access_token_claim] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'defaults for userinfo_token_claim' do
    expect(resource[:userinfo_token_claim]).to eq(:true)
  end

  it 'does not default userinfo_token_claim for saml' do
    config[:protocol] = 'saml'
    expect(resource[:userinfo_token_claim]).to be_nil
  end

  it 'accepts true for userinfo_token_claim' do
    config[:userinfo_token_claim] = true
    expect(resource[:userinfo_token_claim]).to eq(:true)
  end

  it 'accepts true for userinfo_token_claim as string' do
    config[:userinfo_token_claim] = 'true'
    expect(resource[:userinfo_token_claim]).to eq(:true)
  end

  it 'accepts false for userinfo_token_claim' do
    config[:userinfo_token_claim] = false
    expect(resource[:userinfo_token_claim]).to eq(:false)
  end

  it 'accepts false for userinfo_token_claim as string' do
    config[:userinfo_token_claim] = 'false'
    expect(resource[:userinfo_token_claim]).to eq(:false)
  end

  it 'does not accept strings for userinfo_token_claim' do
    config[:userinfo_token_claim] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  defaults = {}

  describe 'basic properties' do
    # Test basic properties
    [
      :claim_name
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

  describe 'full_path' do
    it 'defaults to nil for non groups' do
      expect(resource[:full_path]).to be_nil
    end

    it 'defaults to false for groups' do
      config[:type] = 'oidc-group-membership-mapper'
      expect(resource[:full_path]).to eq(:false)
    end
  end

  it 'accepts Basic for attribute_nameformat' do
    config[:protocol] = 'saml'
    config[:attribute_nameformat] = 'Basic'
    expect(resource[:attribute_nameformat]).to eq(:basic)
  end

  it 'accepts uri for attribute_nameformat' do
    config[:protocol] = 'saml'
    config[:attribute_nameformat] = 'uri'
    expect(resource[:attribute_nameformat]).to eq(:uri)
  end

  it 'does not accept invalid value for attribute_nameformat' do
    config[:protocol] = 'saml'
    config[:attribute_nameformat] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'accepts usermodel_client_role_mapping_client_id' do
    config[:usermodel_client_role_mapping_client_id] = 'foo'
    config[:type] = 'oidc-usermodel-client-role-mapper'
    expect(resource[:usermodel_client_role_mapping_client_id]).to eq('foo')
  end

  it 'errors when usermodel_client_role_mapping_client_id used with wrong type' do
    config[:usermodel_client_role_mapping_client_id] = 'foo'
    config[:type] = 'saml-role-list-mapper'
    expect {
      resource
    }.to raise_error(Puppet::Error)
  end

  it 'accepts value for single' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-role-list-mapper'
    config[:single] = false
    expect(resource[:single]).to eq(:false)
  end

  it 'accepts value for single string' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-role-list-mapper'
    config[:single] = 'false'
    expect(resource[:single]).to eq(:false)
  end

  it 'has default for single' do
    expect(resource[:single]).to be_nil
  end

  it 'has default for single and saml-role-list-mapper' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-role-list-mapper'
    expect(resource[:single]).to eq(:false)
  end

  it 'does not accept invalid value for single' do
    config[:protocol] = 'saml'
    config[:type] = 'saml-role-list-mapper'
    config[:single] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'accepts value for multivalued' do
    config[:multivalued] = false
    expect(resource[:multivalued]).to eq(:false)
  end

  it 'accepts value for multivalued string' do
    config[:multivalued] = 'false'
    expect(resource[:multivalued]).to eq(:false)
  end

  it 'has default for multivalued' do
    expect(resource[:multivalued]).to be_nil
  end

  it 'does not accept invalid value for multivalued' do
    config[:multivalued] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'accepts script' do
    config[:protocol] = 'saml'
    config[:type] = 'script-foo.js'
    config[:single] = true
    config[:attribute_name] = 'foo'
    config[:attribute_nameformat] = 'uri'
    config[:friendly_name] = 'foo'
    expect(resource[:type]).to eq('script-foo.js')
  end

  it 'accepts value for included_client_audience' do
    config[:type] = 'oidc-audience-mapper'
    config[:included_client_audience] = 'foo'
    expect(resource[:included_client_audience]).to eq('foo')
  end

  it 'requires included_client_audience for oidc-audience-mapper' do
    config[:type] = 'oidc-audience-mapper'
    expect { resource }.to raise_error(%r{included_client_audience})
  end

  it 'autorequires keycloak_conn_validator' do
    keycloak_conn_validator = Puppet::Type.type(:keycloak_conn_validator).new(name: 'keycloak')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_conn_validator
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_conn_validator.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires kcadm-wrapper.sh' do
    file = Puppet::Type.type(:file).new(name: 'kcadm-wrapper.sh', path: '/opt/keycloak/bin/kcadm-wrapper.sh')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource file
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(file.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires keycloak_realm' do
    keycloak_realm = Puppet::Type.type(:keycloak_realm).new(name: 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_realm
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_realm.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires keycloak_client' do
    keycloak_client = Puppet::Type.type(:keycloak_client).new(name: 'test.example.com', realm: 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_client
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_client.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end
end
