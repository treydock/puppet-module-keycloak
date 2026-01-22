# frozen_string_literal: true

require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_role_mapping) do
  desc <<-DESC
Attach realm roles to users and groups
@example Ensure that a user has the defined realm roles
  keycloak_role_mapping { 'john-offline_access':
    realm       => 'test',
    name        => 'john',
    realm_roles => ['offline_access'],
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  newparam(:name, namevar: true) do
    desc '--uusername/--gname'
  end

  newparam(:group, boolean: true) do
    desc 'is this a group instead of a user'
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:realm) do
    desc 'realm'
  end

  newproperty(:realm_roles, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'realm roles'
    defaultto []
  end
end
