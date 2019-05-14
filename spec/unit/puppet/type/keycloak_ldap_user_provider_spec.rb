require 'spec_helper'

describe Puppet::Type.type(:keycloak_ldap_user_provider) do
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

  it 'should default to auth_type=none' do
    expect(resource[:auth_type]).to eq('none')
  end

  it 'should not allow invalid auth_type' do
    config[:auth_type] = 'foo'
    expect {
      resource
    }.to raise_error(/foo/)
  end

  it 'should default to edit_mode=READ_ONLY' do
    expect(resource[:edit_mode]).to eq('READ_ONLY')
  end

  it 'should not allow invalid edit_mode' do
    config[:edit_mode] = 'foo'
    expect {
      resource
    }.to raise_error(/foo/)
  end

  it 'should default to vendor=other' do
    expect(resource[:vendor]).to eq('other')
  end

  it 'should not allow invalid vendor' do
    config[:vendor] = 'foo'
    expect {
      resource
    }.to raise_error(/foo/)
  end

  it 'should default to use_truststore_spi=ldapsOnly' do
    expect(resource[:use_truststore_spi]).to eq('ldapsOnly')
  end

  it 'should not allow invalid use_truststore_spi' do
    config[:use_truststore_spi] = 'foo'
    expect {
      resource
    }.to raise_error(/foo/)
  end

  it 'should allow bind_dn' do
    config[:auth_type] = 'simple'
    config[:bind_dn] = 'foo'
    expect(resource[:bind_dn]).to eq('foo')
  end

  it 'should allow bind_credential' do
    config[:auth_type] = 'simple'
    config[:bind_credential] = 'foo'
    expect(resource[:bind_credential]).to eq('foo')
  end

  it 'should allow bind_credential' do
    config[:auth_type] = 'simple'
    config[:use_kerberos_for_password_authentication] = true
    expect(resource[:use_kerberos_for_password_authentication]).to eq(:true)
  end

  it 'should not allow invalid bind_credential' do
    config[:auth_type] = 'simple'
    config[:use_kerberos_for_password_authentication] = 'foo'
    expect {
      resource
    }.to raise_error(/foo/)
  end

  it 'should allow string one for search_scope' do
    config[:search_scope] = 'one'
    expect(resource[:search_scope]).to eq('1')
  end

  it 'should allow string one_level for search_scope' do
    config[:search_scope] = 'one_level'
    expect(resource[:search_scope]).to eq('1')
  end

  it 'should allow string 1 for search_scope' do
    config[:search_scope] = '1'
    expect(resource[:search_scope]).to eq('1')
  end

  it 'should allow 1 for search_scope' do
    config[:search_scope] = 1
    expect(resource[:search_scope]).to eq('1')
  end

  it 'should allow string subtree for search_scope' do
    config[:search_scope] = 'subtree'
    expect(resource[:search_scope]).to eq('2')
  end

  it 'should allow string 2 for search_scope' do
    config[:search_scope] = '2'
    expect(resource[:search_scope]).to eq('2')
  end

  it 'should allow 2 for search_scope' do
    config[:search_scope] = 2
    expect(resource[:search_scope]).to eq('2')
  end

  it 'should not allow invalid search_scope' do
    config[:search_scope] = 'foo'
    expect { resource }.to raise_error(/foo/)
  end

  it 'should default custom_user_search_filter' do
    expect(resource[:custom_user_search_filter]).to eq(:absent)
  end

  it 'should accept valid custom_user_search_filter' do
    config[:custom_user_search_filter] = '(foo=bar)'
    expect(resource[:custom_user_search_filter]).to eq('(foo=bar)')
  end

  it 'should not allow invalid custom_user_search_filter' do
    config[:custom_user_search_filter] = 'foo=bar'
    expect { resource }.to raise_error(Puppet::Error, /must start with "\(" and end with "\)"/)
  end

  defaults = {
    :enabled => :true,
    :priority => '0',
    :batch_size_for_sync => '1000',
    :username_ldap_attribute => 'uid',
    :rdn_ldap_attribute => 'uid',
    :uuid_ldap_attribute => 'entryUUID',
    :import_enabled => :true,
    :user_object_classes => ['inetOrgPerson','organizationalPerson'],
  }

  # Test basic properties
  [
    :users_dn,
    :connection_url,
    :priority,
    :batch_size_for_sync,
    :username_ldap_attribute,
    :rdn_ldap_attribute,
    :uuid_ldap_attribute,
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
    :import_enabled,
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
    :user_object_classes,
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

  it 'should not allow use_kerberos_for_password_authentication with auth_type=none' do
    config[:auth_type] = 'none'
    config[:use_kerberos_for_password_authentication] = true
    expect { resource }.to raise_error(Puppet::Error, /use_kerberos_for_password_authentication is not valid for auth_type none/)
  end

  it 'should not allow bind_credential with auth_type=none' do
    config[:auth_type] = 'none'
    config[:bind_credential] = true
    expect { resource }.to raise_error(Puppet::Error, /bind_credential is not valid for auth_type none/)
  end

  it 'should not allow bind_dn with auth_type=none' do
    config[:auth_type] = 'none'
    config[:bind_dn] = true
    expect { resource }.to raise_error(Puppet::Error, /bind_dn is not valid for auth_type none/)
  end

end
