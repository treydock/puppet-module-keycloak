# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:keycloak_ldap_user_provider) do
  let(:default_config) do
    {
      name: 'foo',
      realm: 'test'
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

  it 'id does not have default' do
    expect(resource[:id]).to eq('b84ed8ed-a7b1-502f-83f6-90132e68adef')
  end

  it 'has realm' do
    expect(resource[:realm]).to eq('test')
  end

  it 'handles componsite name' do
    component = described_class.new(name: 'foo on test')
    expect(component[:name]).to eq('foo on test')
    expect(component[:resource_name]).to eq('foo')
    expect(component[:realm]).to eq('test')
  end

  it 'defaults to auth_type=none' do
    expect(resource[:auth_type]).to eq('none')
  end

  it 'does not allow invalid auth_type' do
    config[:auth_type] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'defaults to edit_mode=READ_ONLY' do
    expect(resource[:edit_mode]).to eq('READ_ONLY')
  end

  it 'does not allow invalid edit_mode' do
    config[:edit_mode] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'defaults to vendor=other' do
    expect(resource[:vendor]).to eq('other')
  end

  it 'does not allow invalid vendor' do
    config[:vendor] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'defaults to use_truststore_spi=always' do
    expect(resource[:use_truststore_spi]).to eq('always')
  end

  it 'does not allow invalid use_truststore_spi' do
    config[:use_truststore_spi] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'allows bind_dn' do
    config[:auth_type] = 'simple'
    config[:bind_dn] = 'foo'
    expect(resource[:bind_dn]).to eq('foo')
  end

  it 'allows bind_credential' do
    config[:auth_type] = 'simple'
    config[:bind_credential] = 'foo'
    expect(resource[:bind_credential]).to eq('foo')
  end

  it 'allows use_kerberos_for_password_authentication' do
    config[:auth_type] = 'simple'
    config[:use_kerberos_for_password_authentication] = true
    expect(resource[:use_kerberos_for_password_authentication]).to eq(:true)
  end

  it 'allows kerberos configuration' do
    config[:auth_type] = 'simple'
    config[:allow_kerberos_authentication] = true
    config[:kerberos_realm] = 'BAR.COM'
    config[:key_tab] = '/etc/krb5.keytab'
    config[:server_principal] = 'host/foo@BAR.COM'
    expect(resource[:allow_kerberos_authentication]).to eq(:true)
    expect(resource[:kerberos_realm]).to eq('BAR.COM')
    expect(resource[:key_tab]).to eq('/etc/krb5.keytab')
    expect(resource[:server_principal]).to eq('host/foo@BAR.COM')
  end

  it 'does not allow invalid bind_credential' do
    config[:auth_type] = 'simple'
    config[:use_kerberos_for_password_authentication] = 'foo'
    expect {
      resource
    }.to raise_error(%r{foo})
  end

  it 'allows string one for search_scope' do
    config[:search_scope] = 'one'
    expect(resource[:search_scope]).to eq('1')
  end

  it 'allows string one_level for search_scope' do
    config[:search_scope] = 'one_level'
    expect(resource[:search_scope]).to eq('1')
  end

  it 'allows string 1 for search_scope' do
    config[:search_scope] = '1'
    expect(resource[:search_scope]).to eq('1')
  end

  it 'allows 1 for search_scope' do
    config[:search_scope] = 1
    expect(resource[:search_scope]).to eq('1')
  end

  it 'allows string subtree for search_scope' do
    config[:search_scope] = 'subtree'
    expect(resource[:search_scope]).to eq('2')
  end

  it 'allows string 2 for search_scope' do
    config[:search_scope] = '2'
    expect(resource[:search_scope]).to eq('2')
  end

  it 'allows 2 for search_scope' do
    config[:search_scope] = 2
    expect(resource[:search_scope]).to eq('2')
  end

  it 'does not allow invalid search_scope' do
    config[:search_scope] = 'foo'
    expect { resource }.to raise_error(%r{foo})
  end

  it 'defaults custom_user_search_filter' do
    expect(resource[:custom_user_search_filter]).to eq(:absent)
  end

  it 'accepts valid custom_user_search_filter' do
    config[:custom_user_search_filter] = '(foo=bar)'
    expect(resource[:custom_user_search_filter]).to eq('(foo=bar)')
  end

  it 'does not allow invalid custom_user_search_filter' do
    config[:custom_user_search_filter] = 'foo=bar'
    expect { resource }.to raise_error(Puppet::Error, %r{must start with "\(" and end with "\)"})
  end

  it 'defaults cache_policy to default' do
    expect(resource[:cache_policy]).to eq(:DEFAULT)
  end

  it 'supports cache_policy to default' do
    config[:cache_policy] = 'EVICT_DAILY'
    expect(resource[:cache_policy]).to eq(:EVICT_DAILY)
  end

  it 'does not allow invalid cache_policy' do
    config[:cache_policy] = 'foo'
    expect { resource }.to raise_error(Puppet::Error)
  end

  defaults = {
    enabled: :true,
    priority: '0',
    batch_size_for_sync: '1000',
    username_ldap_attribute: 'uid',
    rdn_ldap_attribute: 'uid',
    uuid_ldap_attribute: 'entryUUID',
    import_enabled: :true,
    user_object_classes: ['inetOrgPerson', 'organizationalPerson'],
    trust_email: :false,
    full_sync_period: '-1',
    changed_sync_period: '-1',
    sync_registrations: :false
  }

  describe 'basic properties' do
    # Test basic properties
    [
      :users_dn,
      :connection_url,
      :priority,
      :batch_size_for_sync,
      :username_ldap_attribute,
      :rdn_ldap_attribute,
      :uuid_ldap_attribute
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

  describe 'integer properties' do
    # Test integer properties
    [
      :full_sync_period,
      :changed_sync_period
    ].each do |p|
      it "accepts a #{p}" do
        config[p] = 100
        expect(resource[p]).to eq('100')
      end

      next unless defaults[p]

      it "has default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'boolean properties' do
    # Test boolean properties
    [
      :enabled,
      :import_enabled,
      :trust_email,
      :sync_registrations
    ].each do |p|
      it "accepts true for #{p}" do
        config[p] = true
        expect(resource[p]).to eq(:true)
        config[p] = 'true'
        expect(resource[p]).to eq(:true)
      end

      it "accepts false for #{p}" do
        config[p] = false
        expect(resource[p]).to eq(:false)
        config[p] = 'false'
        expect(resource[p]).to eq(:false)
      end

      it "does not accept strings for #{p}" do
        config[p] = 'foo'
        expect {
          resource
        }.to raise_error(%r{foo})
      end

      next unless defaults[p]

      it "has default for #{p}" do
        expect(resource[p]).to eq(defaults[p])
      end
    end
  end

  describe 'array properties' do
    # Array properties
    [
      :user_object_classes
    ].each do |p|
      it 'accepts array' do
        config[p] = ['foo', 'bar']
        expect(resource[p]).to eq(['foo', 'bar'])
      end

      next unless defaults[p]

      it "has default for #{p}" do
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

  it 'does not allow use_kerberos_for_password_authentication with auth_type=none' do
    config[:auth_type] = 'none'
    config[:use_kerberos_for_password_authentication] = true
    expect { resource }.to raise_error(Puppet::Error, %r{use_kerberos_for_password_authentication is not valid for auth_type none})
  end

  it 'does not allow bind_credential with auth_type=none' do
    config[:auth_type] = 'none'
    config[:bind_credential] = true
    expect { resource }.to raise_error(Puppet::Error, %r{bind_credential is not valid for auth_type none})
  end

  it 'does not allow bind_dn with auth_type=none' do
    config[:auth_type] = 'none'
    config[:bind_dn] = true
    expect { resource }.to raise_error(Puppet::Error, %r{bind_dn is not valid for auth_type none})
  end
end
