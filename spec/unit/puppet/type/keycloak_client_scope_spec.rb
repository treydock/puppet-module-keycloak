require 'spec_helper'

describe Puppet::Type.type(:keycloak_client_scope) do
  let(:default_config) do
    {
      :name => 'foo',
      :realm => 'test',
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

  it 'should have id default to name' do
    expect(resource[:id]).to eq('foo')
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

  it 'should default to protocol=openid-connect' do
    expect(resource[:protocol]).to eq('openid-connect')
  end

  it 'should not allow invalid protocol' do
    config[:protocol] = 'foo'
    expect {
      resource
    }.to raise_error(/foo/)
  end

  it 'should have default for consent_screen_text' do
    expect(resource[:consent_screen_text]).to eq('${fooScopeConsentText}')
  end

  it 'should allow values for consent_screen_text' do
    config[:consent_screen_text] = '${foo}'
    expect(resource[:consent_screen_text]).to eq('${foo}')
  end

  defaults = {
    :full_scope_allowed => :true
  }

  # Test boolean properties
  [
    :display_on_consent_screen,
  ].each do |p|
    it "should accept true for #{p.to_s}" do
      config[p] = true
      expect(resource[p]).to eq(:true)
    end
    it "should accept true for #{p.to_s} string" do
      config[p] = 'true'
      expect(resource[p]).to eq(:true)
    end
    it "should accept false for #{p.to_s}" do
      config[p] = false
      expect(resource[p]).to eq(:false)
    end
    it "should accept false for #{p.to_s} string" do
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

end
