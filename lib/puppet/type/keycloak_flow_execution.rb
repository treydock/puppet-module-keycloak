# frozen_string_literal: true

require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'
require_relative '../../puppet_x/keycloak/integer_property'

Puppet::Type.newtype(:keycloak_flow_execution) do
  desc <<-DESC
Manage a Keycloak flow
@example Add an execution to a flow
  keycloak_flow_execution { 'auth-cookie under browser-with-duo on test':
    ensure       => 'present',
    configurable => false,
    display_name => 'Cookie',
    priority     => 10,
    requirement  => 'ALTERNATIVE',
  }

@example Add an execution to a execution flow that is one level deeper than top level
  keycloak_flow_execution { 'auth-username-password-form under form-browser-with-duo on test':
    ensure       => 'present',
    configurable => false,
    display_name => 'Username Password Form',
    priority     => 10,
    requirement  => 'REQUIRED',
  }

@example Add an execution with a configuration
  keycloak_flow_execution { 'duo-mfa-authenticator under form-browser-with-duo on test':
    ensure       => 'present',
    configurable => true,
    display_name => 'Duo MFA',
    alias        => 'Duo',
    config       => {
      "duomfa.akey"    => "foo-akey",
      "duomfa.apihost" => "api-foo.duosecurity.com",
      "duomfa.skey"    => "secret",
      "duomfa.ikey"    => "foo-ikey",
      "duomfa.groups"  => "duo"
    },
    requirement  => 'REQUIRED',
    priority     => 20,
  }

**Autorequires**
* `keycloak_realm` defined for `realm` parameter
* `keycloak_flow` of value defined for `flow_alias`
* `keycloak_flow` if they share same `flow_alias` value and the other resource `priority` is lower
* `keycloak_flow_execution` if `flow_alias` is the same and other `priority` is lower
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The flow execution name'
  end

  newparam(:id) do
    desc 'read-only Id'
  end

  newparam(:provider_id, namevar: true) do
    desc 'provider'
    munge { |v| v.to_s }
  end

  newparam(:flow_alias, namevar: true) do
    desc 'flowAlias'
  end

  newparam(:realm, namevar: true) do
    desc 'realm'
  end

  newparam(:display_name) do
    desc 'displayName'
  end

  newproperty(:priority, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'execution priority'
    munge { |v| v.to_i }
  end

  newproperty(:configurable, boolean: true) do
    desc 'configurable'
    newvalues(:true, :false)
  end

  newproperty(:requirement) do
    desc 'requirement'
    newvalues('DISABLED', 'ALTERNATIVE', 'REQUIRED', 'CONDITIONAL',
              'disabled', 'alternative', 'required', 'conditional')
    defaultto('DISABLED')
    munge { |v| v.upcase.to_s }
  end

  newparam(:alias) do
    desc 'alias'
  end

  newproperty(:config) do
    desc 'execution config'
    validate do |value|
      raise Puppet::Error, 'config must be a Hash' unless value.is_a?(Hash)
    end
    def change_to_s(currentvalue, _newvalue)
      if currentvalue == :absent
        'created config'
      else
        'changed config'
      end
    end

    def is_to_s(_currentvalue) # rubocop:disable Style/PredicateName
      '[old config redacted]'
    end

    def should_to_s(_newvalue)
      '[new config redacted]'
    end
  end

  newparam(:config_id) do
    desc 'read-only config ID'
  end

  def self.title_patterns
    [
      [
        %r{^((\S+) under (\S+) on (\S+))$},
        [
          [:name],
          [:provider_id],
          [:flow_alias],
          [:realm]
        ]
      ],
      [
        %r{(.*)},
        [
          [:name]
        ]
      ]
    ]
  end

  autorequire(:keycloak_flow) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.instance_of?(Puppet::Type::Keycloak_flow)
      next if self[:realm] != resource[:realm]

      if self[:flow_alias] == resource[:alias]
        requires << resource.name
      end
      if !resource[:priority].nil? && !self[:priority].nil? && self[:priority] > resource[:priority] && self[:flow_alias] == resource[:flow_alias]
        requires << resource.name
      end
    end
    requires
  end

  autorequire(:keycloak_flow_execution) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.instance_of?(Puppet::Type::Keycloak_flow_execution)
      next if self[:realm] != resource[:realm]

      if self[:flow_alias] == resource[:flow_alias] && !resource[:priority].nil? && !self[:priority].nil? && self[:priority] > resource[:priority]
        requires << resource.name
      end
    end
    requires
  end

  autorequire(:keycloak_resource_validator) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.instance_of?(Puppet::Type::Keycloak_resource_validator)

      resource[:dependent_resources].to_a.each do |dep|
        requires << resource if dep == "Keycloak_flow_execution[#{self[:name]}]"
      end
    end
    requires
  end

  validate do
    if self[:realm].nil?
      raise "Keycloak_flow_execution[#{self[:name]}] must have a realm defined"
    end

    if self[:ensure] == :present
      if self[:priority].nil?
        raise "Keycloak_flow_execution[#{self[:name]}] priority is required"
      end
      if self[:flow_alias].nil?
        raise "Keycloak_flow_execution[#{self[:name]}] flow_alias is required"
      end
      if self[:provider_id].nil?
        raise "Keycloak_flow_execution[#{self[:name]}] provider_id is required"
      end
    end
  end
end
