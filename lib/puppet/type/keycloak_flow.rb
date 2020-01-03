require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_flow) do
  desc <<-DESC
Manage a Keycloak flow
@example Add custom flow
  keycloak_flow { 'browser-with-duo':
    ensure => 'present',
    realm  => 'test',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The flow name'
  end

  newparam(:id) do
    desc 'Id. Default to `$alias-$realm`'
    defaultto do
      "#{@resource[:alias]}-#{@resource[:realm]}"
    end
  end

  newparam(:alias, namevar: true) do
    desc 'Alias. Default to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:realm, namevar: true) do
    desc 'realm'
  end

  newproperty(:description) do
    desc 'description'
  end

  newproperty(:provider_id) do
    desc 'providerId'
    newvalues('basic-flow', 'form-flow')
    defaultto('basic-flow')
    munge { |v| v.to_s }
  end

  def self.title_patterns
    [
      [
        %r{^((\S+) on (\S+))$},
        [
          [:name],
          [:alias],
          [:realm],
        ],
      ],
      [
        %r{(.*)},
        [
          [:name],
        ],
      ],
    ]
  end

  validate do
    if self[:realm].nil?
      raise "Keycloak_flow[#{self[:name]}] must have a realm defined"
    end
  end
end
