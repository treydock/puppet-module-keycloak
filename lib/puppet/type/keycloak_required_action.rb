require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/integer_property'

Puppet::Type.newtype(:keycloak_required_action) do
  desc <<-DESC
Manage Keycloak required actions
@example Enable Webauthn Register and make it default
  keycloak_required_action { 'webauthn-register on master':
    ensure       => present,
    alias        => 'webauthn-register',
    provider_id  => 'webauthn-register',
    display_name => 'Webauthn Register',
    default      => true,
    enabled      => true,
    priority     => 1,
    config       => {
      'something' => 'true', # keep in mind that keycloak only supports strings for both keys and values
      'smth else' => '1',
    },
  }

  @example Minimal example to enable email verification without making it default
  keycloak_required_action { 'VERIFY_EMAIL on master':
    ensure => present,
  }
  DESC

  extend PuppetX::Keycloak::Type

  ensurable
  add_autorequires

  newparam(:name, namevar: true) do
    desc 'The required action name'
  end

  newparam(:realm, namevar: true) do
    desc 'realm'
  end

  newparam(:alias, namevar: true) do
    desc 'Alias.'
  end

  newparam(:provider_id) do
    desc 'providerId of the required action. Default to `alias`'
    munge { |v| v.to_s }
    defaultto do
      @resource[:alias]
    end
  end

  newproperty(:display_name) do
    desc 'Displayed name.'
    munge { |v| v.to_s }
  end

  newproperty(:enabled, boolean: true) do
    desc 'If the required action is enabled. Default to true.'
    defaultto :true
    newvalues(:true, :false)
    munge { |v| v.to_s == 'true' }
  end

  newproperty(:default, boolean: true) do
    desc 'If the required action is a default one. Default to false'
    defaultto :false
    newvalues(:true, :false)
    munge { |v| v.to_s == 'true' }
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
      is == @should[0] # for whatever reason puppet makes @should an array, so we actually need to compare with first element
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
