# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:keycloak_flow_execution).provider(:kcadm) do
  let(:type) do
    Puppet::Type.type(:keycloak_flow_execution)
  end
  let(:resource) do
    type.new(name: 'foo',
             realm: 'test',
             flow_alias: 'browser-with-duo',
             provider_id: 'auth-username-password-form',
             index: 0)
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:realms).and_return(['test'])
      allow(described_class).to receive(:kcadm).with('get', 'authentication/flows', 'test').and_return(my_fixture_read('get-test.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/flows/browser-with-duo/executions', 'test').and_return(my_fixture_read('get-executions.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/config/be93a426-077f-4235-9686-677ff0706bf8', 'test').and_return('{}')
      expect(described_class.instances.length).to eq(4)
    end

    it 'returns the resource for a flow' do
      allow(described_class).to receive(:realms).and_return(['test'])
      allow(described_class).to receive(:kcadm).with('get', 'authentication/flows', 'test').and_return(my_fixture_read('get-test.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/flows/browser-with-duo/executions', 'test').and_return(my_fixture_read('get-executions.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/config/be93a426-077f-4235-9686-677ff0706bf8', 'test').and_return('{}')
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('auth-cookie under browser-with-duo on test')
    end
  end
  #   describe 'self.prefetch' do
  #     let(:instances) do
  #       all_realms.map { |f| described_class.new(f) }
  #     end
  #     let(:resources) do
  #       all_realms.each_with_object({}) do |f, h|
  #         h[f[:name]] = type.new(f.reject {|k,v| v.nil?})
  #       end
  #     end
  #
  #     before(:each) do
  #       allow(described_class).to receive(:instances).and_return(instances)
  #     end
  #
  #     it 'should prefetch' do
  #       resources.keys.each do |r|
  #         expect(resources[r]).to receive(:provider=).with(described_class)
  #       end
  #       described_class.prefetch(resources)
  #     end
  #   end

  describe 'create' do
    it 'creates a flow execution' do
      temp = Tempfile.new('keycloak_flow_execution')
      allow(Tempfile).to receive(:new).with('keycloak_flow_execution').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/flows/browser-with-duo/executions/execution', 'test', temp.path, nil, true).and_return('uuid') # rubocop:disable RSpec/StubbedMock
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end

    it 'creates a flow execution and updates requirement' do
      resource[:requirement] = 'ALTERNATIVE'
      temp = Tempfile.new('keycloak_flow_execution')
      tempu = Tempfile.new('keycloak_flow_execution_update')
      allow(Tempfile).to receive(:new).with('keycloak_flow_execution').and_return(temp)
      allow(Tempfile).to receive(:new).with('keycloak_flow_execution_update').and_return(tempu)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/flows/browser-with-duo/executions/execution', 'test', temp.path, nil, true).and_return('uuid') # rubocop:disable RSpec/StubbedMock
      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/flows/browser-with-duo/executions', 'test', tempu.path)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end

    it 'creates a flow execution and adds a config' do
      resource[:configurable] = true
      resource[:config] = { 'foo' => 'bar' }
      temp = Tempfile.new('keycloak_flow_execution')
      tempc = Tempfile.new('keycloak_flow_execution_config')
      allow(Tempfile).to receive(:new).with('keycloak_flow_execution').and_return(temp)
      allow(Tempfile).to receive(:new).with('keycloak_flow_execution_config').and_return(tempc)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/flows/browser-with-duo/executions/execution', 'test', temp.path, nil, true).and_return('uuid') # rubocop:disable RSpec/StubbedMock
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/executions/uuid/config', 'test', tempc.path)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'deletes a realm' do
      allow(resource.provider).to receive(:id).and_return('uuid')
      expect(resource.provider).to receive(:kcadm).with('delete', 'authentication/executions/uuid', 'test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'updates a execution requirement' do
      temp = Tempfile.new('keycloak_flow_execution')
      allow(Tempfile).to receive(:new).with('keycloak_flow_execution').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/flows/browser-with-duo/executions', 'test', temp.path, nil, true)
      resource.provider.requirement = 'ALTERNATIVE'
      resource.provider.flush
    end

    it 'updates a config' do
      allow(resource.provider).to receive(:config_id).and_return('uuid')
      temp = Tempfile.new('keycloak_flow_execution_config')
      allow(Tempfile).to receive(:new).with('keycloak_flow_execution_config').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/config/uuid', 'test', temp.path)
      resource.provider.config = { 'foo' => 'bar' }
      resource.provider.flush
    end

    it 'lowers priority twice' do
      allow(resource.provider).to receive(:id).and_return('uuid')
      allow(resource.provider).to receive(:current_priority).and_return(0)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/executions/uuid/lower-priority', 'test').twice
      resource.provider.index = 2
      resource.provider.flush
    end

    it 'lowers priority once' do
      allow(resource.provider).to receive(:id).and_return('uuid')
      allow(resource.provider).to receive(:current_priority).and_return(0)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/executions/uuid/lower-priority', 'test').once
      resource.provider.index = 1
      resource.provider.flush
    end

    it 'raise priority twice' do
      allow(resource.provider).to receive(:id).and_return('uuid')
      allow(resource.provider).to receive(:current_priority).and_return(2)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/executions/uuid/raise-priority', 'test').twice
      resource.provider.index = 0
      resource.provider.flush
    end

    it 'raise priority once' do
      allow(resource.provider).to receive(:id).and_return('uuid')
      allow(resource.provider).to receive(:current_priority).and_return(1)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/executions/uuid/raise-priority', 'test').once
      resource.provider.index = 0
      resource.provider.flush
    end
  end
end
