# frozen_string_literal: true

require_relative './type'

# Class to share among integer properties
class PuppetX::Keycloak::IntegerProperty < Puppet::Property
  validate do |value|
    unless value.to_s =~ %r{^-?\d+$} || value.to_s == 'absent'
      raise ArgumentError, "#{name} should be an Integer"
    end
  end
  munge do |value|
    (value.to_s == 'absent') ? :absent : value.to_i
  end
end
