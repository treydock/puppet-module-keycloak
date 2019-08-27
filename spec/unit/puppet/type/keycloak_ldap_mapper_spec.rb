require 'spec_helper'

describe Puppet::Type.type(:keycloak_ldap_mapper) do
  let(:default_config) do
    {
      name: 'foo',
      realm: 'test',
      ldap: 'ldap-test',
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
    component = described_class.new(name: 'foo for ldap on test')
    expect(component[:name]).to eq('foo for ldap on test')
    expect(component[:resource_name]).to eq('foo')
    expect(component[:ldap]).to eq('ldap')
    expect(component[:realm]).to eq('test')
  end

  it 'handles componsite name with space' do
    component = described_class.new(name: 'full name for ldap on test')
    expect(component[:name]).to eq('full name for ldap on test')
    expect(component[:resource_name]).to eq('full name')
    expect(component[:ldap]).to eq('ldap')
    expect(component[:realm]).to eq('test')
  end

  it 'defaults to type=user-attribute-ldap-mapper' do
    expect(resource[:type]).to eq('user-attribute-ldap-mapper')
  end

  it 'allows valid type' do
    config[:type] = 'full-name-ldap-mapper'
    expect(resource[:type]).to eq('full-name-ldap-mapper')
  end

  it 'does not allow invalid type' do
    config[:type] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'has is_mandatory_in_ldap be nil for full-name-ldap-mapper' do
    config[:type] = 'full-name-ldap-mapper'
    expect(resource[:is_mandatory_in_ldap]).to be_nil
  end

  it 'has is_mandatory_in_ldap default to false for user-attribute-ldap-mapper' do
    config[:type] = 'user-attribute-ldap-mapper'
    expect(resource[:is_mandatory_in_ldap]).to be(:false)
  end

  it 'has always_read_value_from_ldap be nil for full-name-ldap-mapper' do
    config[:type] = 'full-name-ldap-mapper'
    expect(resource[:always_read_value_from_ldap]).to be_nil
  end

  it 'has always_read_value_from_ldap default to true for user-attribute-ldap-mapper' do
    config[:type] = 'user-attribute-ldap-mapper'
    expect(resource[:always_read_value_from_ldap]).to be(:true)
  end

  it 'accepts always_read_value_from_ldap=>false' do
    config[:always_read_value_from_ldap] = false
    expect(resource[:always_read_value_from_ldap]).to eq(:false)
  end

  it 'has write_only with no default' do
    expect(resource[:write_only]).to be_nil
  end

  it 'has write_only default to false for full-name-ldap-mapper' do
    config[:type] = 'full-name-ldap-mapper'
    expect(resource[:write_only]).to be(:false)
  end

  it 'has default mode' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:mode]).to eq('READ_ONLY')
  end

  it 'has default membership_attribute_type' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:membership_attribute_type]).to eq('DN')
  end

  it 'has default user_roles_retrieve_strategy' do
    expect(resource[:user_roles_retrieve_strategy]).to be_nil
  end

  it 'has default user_roles_retrieve_strategy for group-ldap-mapper' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:user_roles_retrieve_strategy]).to eq('LOAD_GROUPS_BY_MEMBER_ATTRIBUTE')
  end

  it 'has default user_roles_retrieve_strategy for role-ldap-mapper' do
    config[:type] = 'role-ldap-mapper'
    expect(resource[:user_roles_retrieve_strategy]).to eq('LOAD_ROLES_BY_MEMBER_ATTRIBUTE')
  end

  it 'has default group_name_ldap_attribute' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:group_name_ldap_attribute]).to eq('cn')
  end

  it 'has default membership_user_ldap_attribute' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:membership_user_ldap_attribute]).to eq('uid')
  end

  it 'has default membership_ldap_attribute' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:membership_ldap_attribute]).to eq('member')
  end

  it 'has default groups_dn' do
    config[:type] = 'group-ldap-mapper'
    config[:groups_dn] = 'foo'
    expect(resource[:groups_dn]).to eq('foo')
  end

  it 'has default memberof_ldap_attribute' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:memberof_ldap_attribute]).to eq('memberOf')
  end

  it 'has default group_object_classes' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:group_object_classes]).to eq('groupOfNames')
  end

  it 'has default roles_dn' do
    config[:type] = 'role-ldap-mapper'
    config[:roles_dn] = 'foo'
    expect(resource[:roles_dn]).to eq('foo')
  end

  it 'has default role_name_ldap_attribute' do
    config[:type] = 'role-ldap-mapper'
    expect(resource[:role_name_ldap_attribute]).to eq('cn')
  end

  it 'has default role_object_classes' do
    config[:type] = 'role-ldap-mapper'
    expect(resource[:role_object_classes]).to eq('groupOfNames')
  end

  it 'has default use_realm_roles_mapping' do
    config[:type] = 'role-ldap-mapper'
    expect(resource[:use_realm_roles_mapping]).to eq(:true)
  end

  it 'supports use_realm_roles_mapping false' do
    config[:type] = 'role-ldap-mapper'
    config[:roles_dn] = 'foo'
    config[:client_id] = 'foo'
    config[:use_realm_roles_mapping] = false
    expect(resource[:use_realm_roles_mapping]).to eq(:false)
  end

  it 'requires client_id for use_realm_roles_mapping=false' do
    config[:type] = 'role-ldap-mapper'
    config[:roles_dn] = 'foo'
    config.delete(:client_id)
    config[:use_realm_roles_mapping] = false
    expect { resource }.to raise_error(Puppet::Error, /client_id/)
  end

  it 'has default ignore_missing_groups' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:ignore_missing_groups]).to eq(:false)
  end

  it 'has default preserve_group_inheritance' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:preserve_group_inheritance]).to eq(:true)
  end

  it 'has default drop_non_existing_groups_during_sync' do
    config[:type] = 'group-ldap-mapper'
    expect(resource[:drop_non_existing_groups_during_sync]).to eq(:false)
  end

  defaults = {
    read_only: :true,
  }

  describe 'basic properties' do
    # Test basic properties
    [
      :ldap,
      :ldap_attribute,
      :user_model_attribute,
      :mapped_group_attributes,
      :groups_ldap_filter,
      :roles_ldap_filter,
    ].each do |p|
      it "should accept a #{p}" do
        config[p] = 'foo'
        expect(resource[p]).to eq('foo')
      end
      next unless defaults[p]
      it "should have default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'boolean properties' do
    # Test boolean properties
    [
      :read_only,
      :write_only,
    ].each do |p|
      it "should accept true for #{p}" do
        config[p] = true
        expect(resource[p]).to eq(:true)
      end
      it "should accept true for #{p} string" do
        config[p] = 'true'
        expect(resource[p]).to eq(:true)
      end
      it "should accept false for #{p}" do
        config[p] = false
        expect(resource[p]).to eq(:false)
      end
      it "should accept false for #{p} string" do
        config[p] = 'false'
        expect(resource[p]).to eq(:false)
      end
      it "should not accept strings for #{p}" do
        config[p] = 'foo'
        expect {
          resource
        }.to raise_error(%r{foo})
      end
      next unless defaults[p]
      it "should have default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
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

  it 'autorequires keycloak_ldap_user_provider' do
    keycloak_ldap_user_provider = Puppet::Type.type(:keycloak_ldap_user_provider).new(name: 'ldap', realm: 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_ldap_user_provider
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_ldap_user_provider.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'autorequires keycloak_client' do
    config[:type] = 'role-ldap-mapper'
    config[:roles_dn] = 'foo'
    config[:use_realm_roles_mapping] = false
    config[:client_id] = 'test.example.com'
    keycloak_client = Puppet::Type.type(:keycloak_client).new(name: 'test.example.com', realm: 'test')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource keycloak_client
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(keycloak_client.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  [
    :realm,
    :ldap,
  ].each do |property|
    it "should require property #{property} when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { resource }.to raise_error(Puppet::Error, %r{You must provide a value for #{property}})
    end
    it "should require property #{property} when ensure => absent" do
      config.delete(property)
      config[:ensure] = :absent
      expect { resource }.to raise_error(Puppet::Error, %r{You must provide a value for #{property}})
    end
  end
end
