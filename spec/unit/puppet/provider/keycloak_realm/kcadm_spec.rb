require 'spec_helper'

describe Puppet::Type.type(:keycloak_realm).provider(:kcadm) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:keycloak_realm)
    @resource = @type.new({
      :name => 'test',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:kcadm).with('get', 'realms').and_return(my_fixture_read('get.out'))
      expect(@provider.instances.length).to eq(2)
    end

    it 'should return the resource for a fileset' do
      allow(@provider).to receive(:kcadm).with('get', 'realms').and_return(my_fixture_read('get.out'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:enabled]).to eq(:true)
      expect(property_hash[:login_with_email_allowed]).to eq(:false)
    end
  end
=begin
  describe 'self.prefetch' do
    let(:instances) do
      all_realms.map { |f| @provider.new(f) }
    end
    let(:resources) do
      all_realms.each_with_object({}) do |f, h|
        h[f[:name]] = @type.new(f.reject {|k,v| v.nil?})
      end
    end

    before(:each) do
      allow(@provider).to receive(:instances).and_return(instances)
    end

    it 'should prefetch' do
      resources.keys.each do |r|
        expect(resources[r]).to receive(:provider=).with(@provider)
      end
      @provider.prefetch(resources)
    end
  end
=end
  describe 'create' do
    it 'should create a realm' do
      temp = Tempfile.new('keycloak_realm')
      allow(Tempfile).to receive(:new).with('keycloak_realm').and_return(temp)
      expect(@resource.provider).to receive(:kcadm).with('create', 'realms', nil, temp.path)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'should delete a realm' do
      expect(@resource.provider).to receive(:kcadm).with('delete', 'realms/test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end

  describe 'flush' do
    it 'should update a realm' do
      temp = Tempfile.new('keycloak_realm')
      allow(Tempfile).to receive(:new).with('keycloak_realm').and_return(temp)
      expect(@resource.provider).to receive(:kcadm).with('update', 'realms/test', nil, temp.path)
      @resource.provider.login_with_email_allowed = false
      @resource.provider.flush
    end
  end

end
