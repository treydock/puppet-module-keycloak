require 'spec_helper'

describe Puppet::Type.type(:keycloak_client_scope).provider(:kcadm) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:keycloak_client_scope)
    @resource = @type.new({
      :name => 'foo',
      :realm => 'test',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:get_realms).and_return(['test', 'master'])
      allow(@provider).to receive(:kcadm).with('get', 'client-scopes', 'master').and_return('[]')
      allow(@provider).to receive(:kcadm).with('get', 'client-scopes', 'test').and_return(my_fixture_read('get-test.out'))
      expect(@provider.instances.length).to eq(6)
    end

    it 'should return the resource for a fileset' do
      allow(@provider).to receive(:get_realms).and_return(['test', 'master'])
      allow(@provider).to receive(:kcadm).with('get', 'client-scopes', 'master').and_return('[]')
      allow(@provider).to receive(:kcadm).with('get', 'client-scopes', 'test').and_return(my_fixture_read('get-test.out'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('email on test')
    end
  end

  describe 'create' do
    it 'should create a realm' do
      temp = Tempfile.new('keycloak_client_scope')
      allow(Tempfile).to receive(:new).with('keycloak_client_scope').and_return(temp)
      expect(@resource.provider).to receive(:kcadm).with('create', 'client-scopes', 'test', temp.path)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'should delete a realm' do
      hash = @resource.provider.instance_variable_get(:@property_hash)
      hash = @resource.to_hash
      @resource.provider.instance_variable_set(:@property_hash, hash)
      expect(@resource.provider).to receive(:kcadm).with('delete', 'client-scopes/foo', 'test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'should update a realm' do
      hash = @resource.provider.instance_variable_get(:@property_hash)
      hash = @resource.to_hash
      @resource.provider.instance_variable_set(:@property_hash, hash)
      temp = Tempfile.new('keycloak_client_scope')
      allow(Tempfile).to receive(:new).with('keycloak_client_scope').and_return(temp)
      expect(@resource.provider).to receive(:kcadm).with('update', 'client-scopes/foo', 'test', temp.path)
      @resource.provider.consent_screen_text = '${foo}'
      @resource.provider.flush
    end
  end

end
