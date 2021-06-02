require_relative '../../puppet_x/keycloak/integer_property'

Puppet::Type.newtype(:keycloak_resource_validator) do
  desc <<-DESC
Verify that a specific Keycloak resource is available
  DESC

  ensurable

  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:test_url) do
    desc 'URL to use for testing if the Keycloak database is up'
  end

  newparam(:test_key) do
    desc 'Key to lookup'
  end

  newparam(:test_value) do
    desc 'Value to lookup'
  end

  newparam(:realm) do
    desc 'Realm to query'
  end

  newparam(:timeout) do
    desc 'The max number of seconds that the validator should wait before giving up and deciding that keycloak is not running; defaults to 15 seconds.'
    defaultto 30

    validate do |value|
      # This will raise an error if the string is not convertible to an integer
      Integer(value)
    end

    munge do |value|
      Integer(value)
    end
  end

  newparam(:dependent_resources) do
    desc 'Resources that should autorequire this validator, eg: Keycloak_flow_execution[foobar]'
  end

  validate do
    if self[:test_url].nil?
      raise "Keycloak_resource_validator[#{self[:name]}] test_url is required"
    end
    if self[:test_key].nil?
      raise "Keycloak_resource_validator[#{self[:name]}] test_key is required"
    end
    if self[:test_value].nil?
      raise "Keycloak_resource_validator[#{self[:name]}] test_value is required"
    end
  end
end
