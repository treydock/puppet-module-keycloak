require 'spec_helper'

describe Puppet::Type.type(:keycloak_client).provider(:kcadm) do
  let(:type) do
    Puppet::Type.type(:keycloak_client)
  end
  let(:resource) do
    type.new(name: 'foo',
             realm: 'test',
             default_client_scopes: ['profile'])
  end

  describe 'self.instances' do
    it 'creates instances' do
      allow(described_class).to receive(:realms).and_return(['test', 'master'])
      allow(described_class).to receive(:kcadm).with('get', 'clients', 'master').and_return(my_fixture_read('get-master.out'))
      allow(described_class).to receive(:kcadm).with('get', 'clients', 'test').and_return(my_fixture_read('get-test.out'))
      allow(described_class).to receive(:kcadm).with('get', 'clients/example.com/client-secret', 'test').and_return(my_fixture_read('get-client-secret.out'))
      expect(described_class.instances.length).to eq(7 + 6)
    end

    it 'returns the resource for a fileset' do
      allow(described_class).to receive(:realms).and_return(['test', 'master'])
      allow(described_class).to receive(:kcadm).with('get', 'clients', 'master').and_return(my_fixture_read('get-master.out'))
      allow(described_class).to receive(:kcadm).with('get', 'clients', 'test').and_return(my_fixture_read('get-test.out'))
      allow(described_class).to receive(:kcadm).with('get', 'clients/example.com/client-secret', 'test').and_return(my_fixture_read('get-client-secret.out'))
      property_hash = described_class.instances[0].instance_variable_get('@property_hash')
      expect(property_hash[:name]).to eq('example.com on test')
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
      temp = Tempfile.new('keycloak_client')
      allow(Tempfile).to receive(:new).with('keycloak_client').and_return(temp)
      allow(resource.provider).to receive(:kcadm).with('get', 'client-scopes', 'test', nil, ['id', 'name']).and_return(my_fixture_read('get-scopes.out'))
      expect(resource.provider).to receive(:kcadm).with('create', 'clients', 'test', temp.path).and_return(my_fixture_read('get-client.out'))
      expect(resource.provider).to receive(:kcadm).with('delete', 'clients/foo/default-client-scopes/b8ebafcc-485f-44d2-9fe6-f4ed0da80980', 'test')
      expect(resource.provider).to receive(:kcadm).with('delete', 'clients/foo/default-client-scopes/3e40378d-d26d-471f-b2c7-7a3d9651e588', 'test')
      expect(resource.provider).to receive(:kcadm).with('delete', 'clients/foo/optional-client-scopes/96f8b56b-7b3a-44cf-82a5-ffbda49271bd', 'test')
      expect(resource.provider).to receive(:kcadm).with('delete', 'clients/foo/optional-client-scopes/a83d9575-d122-4af1-afb0-10edb851798e', 'test')
      expect(resource.provider).to receive(:kcadm).with('delete', 'clients/foo/optional-client-scopes/dbd3b1c1-9159-46d9-a879-9602972f1994', 'test')
      expect(resource.provider).to receive(:kcadm).with('update', 'clients/foo/default-client-scopes/ee85ec64-4853-4fd4-a2f4-ff578016c9b5', 'test')
      resource.provider.create
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'deletes a realm' do
      hash = resource.to_hash
      resource.provider.instance_variable_set(:@property_hash, hash)
      expect(resource.provider).to receive(:kcadm).with('delete', 'clients/foo', 'test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get('@property_hash')
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'updates a realm' do
      hash = resource.to_hash
      resource.provider.instance_variable_set(:@property_hash, hash)
      temp = Tempfile.new('keycloak_client')
      allow(Tempfile).to receive(:new).with('keycloak_client').and_return(temp)
      expect(resource.provider).to receive(:kcadm).with('update', 'clients/foo', 'test', temp.path)
      resource.provider.redirect_uris = ['foobar']
      resource.provider.flush
    end

    it 'updates default_client_scopes' do
      hash = resource.to_hash
      resource.provider.instance_variable_set(:@property_hash, hash)
      temp = Tempfile.new('keycloak_client')
      allow(Tempfile).to receive(:new).with('keycloak_client').and_return(temp)
      allow(resource.provider).to receive(:kcadm).with('get', 'client-scopes', 'test', nil, ['id', 'name']).and_return(my_fixture_read('get-scopes.out'))
      expect(resource.provider).to receive(:kcadm).with('update', 'clients/foo', 'test', temp.path)
      expect(resource.provider).to receive(:kcadm).with('delete', 'clients/foo/default-client-scopes/ee85ec64-4853-4fd4-a2f4-ff578016c9b5', 'test')
      expect(resource.provider).to receive(:kcadm).with('update', 'clients/foo/default-client-scopes/openid-connect-clients', 'test')
      resource.provider.default_client_scopes = ['openid-connect-clients']
      resource.provider.redirect_uris = ['foobar']
      resource.provider.flush
    end
  end
end
