# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:keycloak_flow).provider(:kcadm) do
  let(:type) do
    Puppet::Type.type(:keycloak_flow)
  end
  let(:resource) do
    type.new(name: 'foo',
             realm: 'test')
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:realms).and_return(['test'])
      allow(described_class).to receive(:kcadm).with('get', 'authentication/flows', 'test').and_return(my_fixture_read('get-test.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/flows/browser-with-duo/executions', 'test').and_return(my_fixture_read('get-executions.out'))
      expect(described_class.instances.length).to eq(3)
    end

    it 'returns the resource for a flow' do
      allow(described_class).to receive(:realms).and_return(['test'])
      allow(described_class).to receive(:kcadm).with('get', 'authentication/flows', 'test').and_return(my_fixture_read('get-test.out'))
      allow(described_class).to receive(:kcadm).with('get', 'authentication/flows/browser-with-duo/executions', 'test').and_return(my_fixture_read('get-executions.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('browser-with-duo on test')
      property_hash = described_class.instances[1].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('form-browser-with-duo under browser-with-duo on test')
      property_hash = described_class.instances[2].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('check-duo under form-browser-with-duo on test')
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
    it 'creates a flow' do
      temp = Tempfile.new('keycloak_flow')
      allow(Tempfile).to receive(:new).with('keycloak_flow').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/flows', 'test', temp.path, nil, true)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end

    it 'creates a flow and updates requirement' do
      resource[:top_level] = false
      resource[:requirement] = 'ALTERNATIVE'
      resource[:flow_alias] = 'browser-with-duo'
      temp = Tempfile.new('keycloak_flow')
      tempu = Tempfile.new('keycloak_flow_execution')
      allow(Tempfile).to receive(:new).with('keycloak_flow').and_return(temp)
      allow(Tempfile).to receive(:new).with('keycloak_flow_execution').and_return(tempu)
      uid = '53751618-6a49-4682-b4e8-624f170b8507'
      expect(resource.provider).to receive(:kcadm).with('get', 'authentication/flows/browser-with-duo/executions', 'test').and_return(my_fixture_read('get-executions.out')) # rubocop:disable RSpec/StubbedMock
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/flows/browser-with-duo/executions/flow', 'test', temp.path, nil, true).and_return(uid) # rubocop:disable RSpec/StubbedMock
      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/flows/browser-with-duo/executions', 'test', tempu.path, nil, true)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'deletes a flow' do
      hash = resource.to_hash
      resource.provider.instance_variable_set(:@property_hash, hash)
      expect(resource.provider).to receive(:kcadm).with('delete', 'authentication/flows/foo-test', 'test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end

    it 'deletes a flow that is not top level' do
      allow(resource.provider).to receive(:id).and_return('uuid')
      resource[:top_level] = false
      expect(resource.provider).to receive(:kcadm).with('delete', 'authentication/executions/uuid', 'test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'updates a flow' do
      hash = resource.to_hash
      resource.provider.instance_variable_set(:@property_hash, hash)
      temp = Tempfile.new('keycloak_flow')
      allow(Tempfile).to receive(:new).with('keycloak_flow').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/flows/foo-test', 'test', temp.path, nil, true)
      resource.provider.description = 'foobar'
      resource.provider.flush
    end

    it 'updates a execution requirement' do
      resource[:flow_alias] = 'browser-with-duo'
      resource[:top_level] = false
      temp = Tempfile.new('keycloak_flow')
      allow(Tempfile).to receive(:new).with('keycloak_flow').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/flows/browser-with-duo/executions', 'test', temp.path, nil, true)
      resource.provider.requirement = 'ALTERNATIVE'
      resource.provider.flush
    end
  end
end
