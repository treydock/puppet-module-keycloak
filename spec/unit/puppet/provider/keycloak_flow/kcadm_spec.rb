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
      expect(described_class.instances.length).to eq(9)
    end

    it 'returns the resource for a flow' do
      allow(described_class).to receive(:realms).and_return(['test'])
      allow(described_class).to receive(:kcadm).with('get', 'authentication/flows', 'test').and_return(my_fixture_read('get-test.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('first broker login on test')
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
      temp = Tempfile.new('keycloak_flow')
      allow(Tempfile).to receive(:new).with('keycloak_flow').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('create', 'authentication/flows', 'test', temp.path)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'deletes a realm' do
      hash = resource.to_hash
      resource.provider.instance_variable_set(:@property_hash, hash)
      expect(resource.provider).to receive(:kcadm).with('delete', 'authentication/flows/foo-test', 'test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'updates a realm' do
      hash = resource.to_hash
      resource.provider.instance_variable_set(:@property_hash, hash)
      temp = Tempfile.new('keycloak_flow')
      allow(Tempfile).to receive(:new).with('keycloak_flow').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('update', 'authentication/flows/foo-test', 'test', temp.path)
      resource.provider.description = 'foobar'
      resource.provider.flush
    end
  end
end
