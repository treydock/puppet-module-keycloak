require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'
require_relative '../../puppet_x/keycloak/integer_property'

Puppet::Type.newtype(:keycloak_flow) do
  desc <<-DESC
Manage a Keycloak flow
@example Add custom flow
  keycloak_flow { 'browser-with-duo':
    ensure => 'present',
    realm  => 'test',
  }

@example Add a flow execution to existing browser-with-duo flow
  keycloak_flow { 'form-browser-with-duo under browser-with-duo on test':
    ensure      => 'present',
    index       => 2,
    requirement => 'ALTERNATIVE',
    top_level   => false,
  }

**Autorequires**
* `keycloak_realm` defined for `realm` parameter
* `keycloak_flow` of `flow_alias` if `top_level=false`
* `keycloak_flow` of `flow_alias` if other `index` is lower and if `top_level=false`
* `keycloak_flow_execution` if `flow_alias` is the same and other `index` is lower and if `top_level=false`
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The flow name'
  end

  newparam(:id) do
    desc 'Id. Default to `$alias-$realm` when top_level is true. Only applies to top_level=true'
    defaultto do
      if @resource[:top_level] == :false
        nil
      else
        "#{@resource[:alias]}-#{@resource[:realm]}"
      end
    end
  end

  newparam(:alias, namevar: true) do
    desc 'Alias. Default to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:flow_alias, namevar: true) do
    desc 'flowAlias, required for top_level=false'
  end

  newparam(:realm, namevar: true) do
    desc 'realm'
  end

  newparam(:provider_id) do
    desc 'providerId'
    newvalues('basic-flow', 'form-flow')
    defaultto('basic-flow')
    munge { |v| v.to_s }
  end

  newparam(:type) do
    desc 'sub-flow execution provider, default to `registration-page-form` for top_level=false and does not apply to top_level=true'
    defaultto do
      if @resource[:top_level] == :false
        'registration-page-form'
      else
        nil
      end
    end
    munge { |v| v.to_s }
  end

  newparam(:top_level, boolean: true) do
    desc 'topLevel'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newproperty(:index, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'execution index, only applied to top_level=false, required for top_level=false'
  end

  newproperty(:description) do
    desc 'description'
  end

  newproperty(:requirement) do
    desc 'requirement, only applied to top_level=false and defaults to DISABLED'
    newvalues('DISABLED', 'ALTERNATIVE', 'REQUIRED', 'CONDITIONAL',
              'disabled', 'alternative', 'required', 'conditional')
    defaultto do
      if @resource[:top_level] == :false
        'DISABLED'
      else
        nil
      end
    end
    munge { |v| v.upcase.to_s }
  end

  def self.title_patterns
    [
      [
        %r{^((\S+) under (\S+) on (\S+))$},
        [
          [:name],
          [:alias],
          [:flow_alias],
          [:realm],
        ],
      ],
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

  autorequire(:keycloak_flow) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.class.to_s == 'Puppet::Type::Keycloak_flow'
      next if self[:realm] != resource[:realm]
      next if self[:top_level] == :true
      if self[:flow_alias] == resource[:alias]
        requires << resource.name
      end
      if !resource[:index].nil? && !self[:index].nil? && self[:index] > resource[:index] && self[:flow_alias] == resource[:flow_alias]
        requires << resource.name
      end
    end
    requires
  end

  autorequire(:keycloak_flow_execution) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.class.to_s == 'Puppet::Type::Keycloak_flow_execution'
      next if self[:realm] != resource[:realm]
      next if self[:top_level] == :true
      if self[:flow_alias] == resource[:flow_alias] && !self[:index].nil? && !resource[:index].nil? && self[:index] > resource[:index]
        requires << resource.name
      end
    end
    requires
  end

  autorequire(:keycloak_resource_validator) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.class.to_s == 'Puppet::Type::Keycloak_resource_validator'
      resource[:dependent_resources].to_a.each do |dep|
        requires << resource if dep == "Keycloak_flow[#{self[:name]}]"
      end
    end
    requires
  end

  validate do
    if self[:realm].nil?
      raise "Keycloak_flow[#{self[:name]}] must have a realm defined"
    end
    if self[:ensure] == :present
      if self[:top_level] == :false && self[:index].nil?
        raise "Keycloak_flow[#{self[:name]}] index is required when top_level is false"
      end
      if self[:top_level] == :false && self[:flow_alias].nil?
        raise "Keycloak_flow[#{self[:name]}] flow_alias is required when top_level is false"
      end
    end
  end
end
