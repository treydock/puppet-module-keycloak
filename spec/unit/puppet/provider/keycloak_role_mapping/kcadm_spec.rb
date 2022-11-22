# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:keycloak_role_mapping).provider(:kcadm) do
  let(:type) do
    Puppet::Type.type(:keycloak_role_mapping)
  end

  describe 'add realm roles' do
    let(:resource) do
      type.new(name: 'role-mapping',
               group: false,
               realm: 'test',
               realm_roles: ['a', 'b', 'c'])
    end

    it 'has added realm role' do
      allow(resource.provider).to receive(:kcadm)
      allow(resource.provider).to receive(:realm_roles).and_return(['a', 'b'])
      expect(resource.provider).to receive(:add_roles).with(['c'])
      resource.provider.realm_roles= ['a', 'b', 'c'] # rubocop:disable Layout/SpaceAroundOperators
    end
  end

  describe 'remove realm roles' do
    let(:resource) do
      type.new(name: 'role-mapping',
               group: false,
               realm: 'test',
               realm_roles: ['a'])
    end

    it 'has removed realm role' do
      allow(resource.provider).to receive(:kcadm)
      allow(resource.provider).to receive(:realm_roles).and_return(['a', 'b'])
      expect(resource.provider).to receive(:remove_roles).with(['b'])
      resource.provider.realm_roles= ['a'] # rubocop:disable Layout/SpaceAroundOperators
    end
  end
end
