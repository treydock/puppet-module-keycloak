# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:keycloak_required_action).provider(:kcadm) do
  let(:type) do
    Puppet::Type.type(:keycloak_required_action)
  end
  let(:resource) do
    type.new(name: 'foo',
             realm: 'test',
             provider_id: 'webauthn-register',)
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:realms).and_return(['master', 'test'])
      allow(described_class).to receive(:kcadm).with('get', 'authentication/required-actions', 'master').and_return(my_fixture_read('get-master.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/unregistered-required-actions', 'master').and_return(my_fixture_read('get-unregistered-required-actions-master.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/required-actions', 'test').and_return(my_fixture_read('get-test.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/unregistered-required-actions', 'test').and_return(my_fixture_read('get-unregistered-required-actions-test.out'))

      expect(described_class.instances.length).to eq(16)
    end

    it 'returns the resource for a required action' do
      allow(described_class).to receive(:realms).and_return(['test'])
      allow(described_class).to receive(:kcadm).with('get', 'authentication/required-actions', 'test').and_return(my_fixture_read('get-test.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/unregistered-required-actions', 'test').and_return('[]')

      property_hash = described_class.instances[0].instance_variable_get('@property_hash')

      expect(property_hash[:name]).to eq('webauthn-register on test')
    end
  end

  describe 'create' do
    it 'registers a required action' do
      temp = Tempfile.new('keycloak_required_action_register')
      allow(Tempfile).to receive(:new).with('keycloak_required_action_register').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/register-required-action', 'test', temp.path)

      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')

      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'deregisters a required action' do
      resource.provider.instance_variable_set(:@property_hash, resource.to_hash)

      expect(resource.provider).to receive(:kcadm).with('delete', 'authentication/required-actions/webauthn-register', 'test')

      resource.provider.destroy

      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'does not do anything without pending changes' do
      resource.provider.instance_variable_set(:@property_hash, resource.to_hash)

      expect(resource.provider).not_to receive(:kcadm)

      resource.provider.flush
    end

    it 'configures a required action' do
      resource.provider.instance_variable_set(:@property_hash, resource.to_hash)
      temp = Tempfile.new('keycloak_required_action_configure')
      allow(Tempfile).to receive(:new).with('keycloak_required_action_configure').and_return(temp)

      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/required-actions/webauthn-register', 'test', temp.path)

      resource.provider.display_name = 'something'
      resource.provider.flush
    end

    # If developer does not specify the display name, the api would use the name
    # that is initially returned from unregistered-required-actions
    it 'uses display_name from current state if none specified explicitly' do
      resource.provider.instance_variable_set(:@property_hash, display_name: 'display name', provider_id: 'webauthn-register')
      temp = Tempfile.new('keycloak_required_action_configure')
      allow(Tempfile).to receive(:new).with('keycloak_required_action_configure').and_return(temp)

      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/required-actions/webauthn-register', 'test', temp.path)

      resource.provider.priority = 1000
      resource.provider.flush

      data = IO.read(temp.path)
      json = JSON.parse(data)
      expect(json['name']).to eq('display name')
    end

    it 'uses provided display_name' do
      resource[:display_name] = 'something'
      resource.provider.instance_variable_set(:@property_hash, resource.to_hash)
      temp = Tempfile.new('keycloak_required_action_configure')
      allow(Tempfile).to receive(:new).with('keycloak_required_action_configure').and_return(temp)

      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/required-actions/webauthn-register', 'test', temp.path)

      resource.provider.priority = 200
      resource.provider.flush

      data = IO.read(temp.path)
      json = JSON.parse(data)
      expect(json['name']).to eq('something')
    end
  end
end
