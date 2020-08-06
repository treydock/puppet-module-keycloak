# require_relative '../provider/keycloak_api'
require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'
require_relative '../../puppet_x/keycloak/integer_property'

Puppet::Type.newtype(:keycloak_required_action) do
  desc <<-DESC
Manage Keycloak required actions
@example Enable Webauthn Register and make it default
  keycloak_required_action { 'Webauthn Register on master':
    ensure => 'present',
    provider_id => 'webauthn-register',
    display_name => 'Webauthn Register',
    default => true,
    enabled => true,
    priority => 1,
    config => {},
    alias => 'smh'
  }
  DESC

  extend PuppetX::Keycloak::Type
  # add_autorequires

  ensurable

  newparam(:id) do
    desc 'Id.'
  end

  newparam(:name, namevar: true) do
    desc 'The required action name'
  end

  newparam(:realm, namevar: true) do
    desc 'realm'
  end

  newparam(:provider_id, namevar: true) do
    desc 'providerId of the required action'
    munge { |v| v.to_s }
  end

  newproperty(:display_name) do
    desc 'Displayed name'
    defaultto do
      @resource[:provider_id]
    end
    munge { |v| v.to_s }
  end

  newproperty(:enabled, boolean: true) do
    desc 'If the required action is marked enabled (only for ensure => present)'
    defaultto true
  end

  newproperty(:alias) do
    desc 'Alias. Default to `provider_id`.'
    defaultto do
      @resource[:provider_id]
    end
  end

  newproperty(:default, boolean: true) do
    desc 'If the required action is a default one'
    defaultto false
  end

  newproperty(:priority, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'Required action priority'
  end

  newproperty(:config, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'Required action config'
  end

  # autorequire(:keycloak_ldap_user_provider) do
  #   requires = []
  #   catalog.resources.each do |resource|
  #     next unless resource.class.to_s == 'Puppet::Type::Keycloak_ldap_user_provider'
  #     if self[:ldap] == "#{resource[:resource_name]}-#{resource[:realm]}"
  #       requires << resource.name
  #     end
  #   end
  #   requires
  # end

  # autorequire(:keycloak_client) do
  #   requires = []
  #   if self[:type] == 'role-ldap-mapper'
  #     if self[:use_realm_roles_mapping].to_sym == :false
  #       requires = [self[:client_id]]
  #     end
  #   end
  #   requires
  # end

  def self.title_patterns
    [
      [ # TODO: use provider id here? see the keycloak_flow_execution
        %r{^((\S+) on (\S+))$},
        [
          [:name],
          [:provider_id],
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
    required_properties = [
      :alias,
      :realm,
    ]
    required_properties.each do |property|
      if self[property].nil?
        raise Puppet::Error, "Keycloak_required_action[#{self[:name]}] must have a #{property} defined"
      end
    end
    if self[:ensure] == :present
      # if self[:priority].nil?
      #   raise "Keycloak_required_action[#{self[:name]}] priority is required"
      # end
      if self[:provider_id].nil?
        raise "Keycloak_required_action[#{self[:name]}] provider_id is required"
      end
    end
  end
end
