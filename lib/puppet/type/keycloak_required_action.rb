require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'
require_relative '../../puppet_x/keycloak/integer_property'

Puppet::Type.newtype(:keycloak_required_action) do
  desc <<-DESC
Manage Keycloak required actions
@example Enable Webauthn Register and make it default
  keycloak_required_action { 'webauthn-register on master':
    ensure => present,
    provider_id => 'webauthn-register',
    display_name => 'Webauthn Register',
    default => true,
    enabled => true,
    priority => 1,
    config => {
      'something' => 'true', # keep in mind that keycloak only supports strings for both keys and values
      'smth else' => '1',
    },
    alias => 'webauthn',
  }

  @example Minimal example to enable email verification without making it default
  keycloak_required_action { 'VERIFY_EMAIL on master':
    ensure => present,
  }
  DESC

  extend PuppetX::Keycloak::Type

  ensurable

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
    desc 'Displayed name. Default to `provider_id`'
    defaultto do
      @resource[:provider_id]
    end
    munge { |v| v.to_s }
  end

  newproperty(:enabled, boolean: true) do
    desc 'If the required action is enabled. Default to true.'
    defaultto true
  end

  newproperty(:alias) do
    desc 'Alias. Default to `provider_id`.'
    defaultto do
      @resource[:provider_id]
    end
  end

  newproperty(:default, boolean: true) do
    desc 'If the required action is a default one. Default to false'
    defaultto false
  end

  newproperty(:priority, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'Required action priority'
  end

  newproperty(:config) do
    desc 'Required action config'
    validate do |value|
      raise Puppet::Error, 'config must be a Hash' unless value.is_a?(Hash)
    end
    def insync?(is)
      is == @should
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

  def self.title_patterns
    [
      [
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
      if self[:provider_id].nil?
        raise Puppet::Error, "Keycloak_required_action[#{self[:name]}] provider_id is required"
      end
    end
  end
end
