require 'spec_helper'

describe Puppet::Type.type(:keycloak_client_protocol_mapper).provider(:kcadm) do
  let(:type) do
    Puppet::Type.type(:keycloak_client_protocol_mapper)
  end
  let(:resource) do
    type.new(name: 'foo',
             realm: 'test',
             client: 'test.local')
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:realms).and_return(['master', 'test'])
      allow(described_class).to receive(:kcadm).with('get', 'clients', 'master').and_return(my_fixture_read('get-master.out'))
      allow(described_class).to receive(:kcadm).with('get', 'clients', 'test').and_return(my_fixture_read('get-test.out'))
      expect(described_class.instances.length).to eq(74)
    end

    it 'returns the resource for a protocol mapper' do
      allow(described_class).to receive(:realms).and_return(['master', 'test'])
      allow(described_class).to receive(:kcadm).with('get', 'clients', 'master').and_return(my_fixture_read('get-master.out'))
      allow(described_class).to receive(:kcadm).with('get', 'clients', 'test').and_return(my_fixture_read('get-test.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('full name for 4fa1df25-5754-45d2-902c-59a5cd50d6b8 on master')
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
    it 'creates a realm' do
      temp = Tempfile.new('keycloak_protocol_mapper')
      allow(Tempfile).to receive(:new).with('keycloak_protocol_mapper').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('create', 'clients/test.local/protocol-mappers/models', 'test', temp.path)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'deletes a realm' do
      allow(resource.provider).to receive(:id).and_return('b84ed8ed-a7b1-502f-83f6-90132e68adef')
      expect(resource.provider).to receive(:kcadm).with('delete', 'clients/test.local/protocol-mappers/models/b84ed8ed-a7b1-502f-83f6-90132e68adef', 'test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'updates a realm' do
      allow(resource.provider).to receive(:id).and_return('b84ed8ed-a7b1-502f-83f6-90132e68adef')
      temp = Tempfile.new('keycloak_protocol_mapper')
      allow(Tempfile).to receive(:new).with('keycloak_protocol_mapper').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('update', 'clients/test.local/protocol-mappers/models/b84ed8ed-a7b1-502f-83f6-90132e68adef', 'test', temp.path)
      resource.provider.claim_name = 'test'
      resource.provider.flush
    end
  end
end
