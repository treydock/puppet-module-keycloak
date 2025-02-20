# frozen_string_literal: true

require 'puppet'
require 'json'

# Shared provider class
class Puppet::Provider::KeycloakAPI < Puppet::Provider
  initvars

  # Unused but defined anyways
  commands kcadm_wrapper: '/opt/keycloak/bin/kcadm-wrapper.sh'

  @install_dir = nil
  @server = nil
  @realm = nil
  @user = nil
  @password = nil
  @use_wrapper = true
  @keycloak_user = 'keycloak'
  @keycloak_group = 'keycloak'

  class << self
    attr_accessor :install_dir, :server, :realm, :user, :password, :use_wrapper,
                  :keycloak_user, :keycloak_group
  end

  def self.type_properties
    resource_type.validproperties.reject { |p| [:ensure, :custom_properties].include? p.to_sym }
  end

  def type_properties
    self.class.type_properties
  end

  def self.camelize(value)
    str = value.to_s.split('_').map(&:capitalize).join
    str[0].downcase + str[1..-1]
  end

  def camelize(*args)
    self.class.camelize(*args)
  end

  def self.escape(str)
    str.gsub(' ', '%20')
  end

  def convert_property_value(value)
    case value
    when :true
      true
    when :false
      false
    else
      value
    end
  end

  def self.kcadm(action, resource, realm = nil, file = nil, fields = nil, print_id = false, params = nil)
    kcadm_wrapper = '/opt/keycloak/bin/kcadm-wrapper.sh'

    arguments = [action]

    # get-roles does not accept a resource as its parameter
    arguments << escape(resource) if resource

    if ['create', 'update'].include?(action) && !print_id
      arguments << '-o'
    end

    if realm
      arguments << '-r'
      arguments << escape(realm)
    end
    if file
      arguments << '-f'
      arguments << file
    end
    if fields
      arguments << '--fields'
      arguments << fields.join(',')
    end
    params&.each do |param, value|
      case value
      when String
        arguments << "--#{param}"
        arguments << value
      when Array
        value.each do |val|
          arguments << "--#{param}"
          arguments << val
        end
      end
    end
    if action == 'create' && print_id
      arguments << '--id'
    end
    if use_wrapper == false || use_wrapper == :false
      auth_arguments = [
        '--no-config',
        '--server', server,
        '--realm', escape(self.realm),
        '--user', user,
        '--password', password
      ]
      cmd = [File.join(install_dir, 'bin/kcadm.sh')] + arguments + auth_arguments
    else
      cmd = [kcadm_wrapper] + arguments
    end

    cmd.reject! { |c| c.empty? }

    execute(cmd, combine: false, failonfail: true, uid: keycloak_user, gid: keycloak_group)
  end

  def kcadm(*args)
    self.class.kcadm(*args)
  end

  def self.realms
    output = kcadm('get', 'realms', nil, nil, ['realm'])
  rescue Puppet::ExecutionFailure => e
    Puppet.notice("Failed to get realms: #{e}")
    []
  else
    data = JSON.parse(output)
    data.map { |r| r['realm'] }
  end

  def realms
    self.class.realms
  end

  def self.name_uuid(name)
    # Code lovingly taken from
    # https://github.com/puppetlabs/marionette-collective/blob/master/lib/mcollective/ssl.rb

    # This is the UUID version 5 type DNS name space which is as follows:
    #
    #  6ba7b810-9dad-11d1-80b4-00c04fd430c8
    #
    uuid_name_space_dns = [0x6b,
                           0xa7,
                           0xb8,
                           0x10,
                           0x9d,
                           0xad,
                           0x11,
                           0xd1,
                           0x80,
                           0xb4,
                           0x00,
                           0xc0,
                           0x4f,
                           0xd4,
                           0x30,
                           0xc8].map { |b| b.chr }.join

    sha1 = Digest::SHA1.new
    sha1.update(uuid_name_space_dns)
    sha1.update(name)

    # first 16 bytes..
    bytes = sha1.digest[0, 16].bytes.to_a

    # version 5 adjustments
    bytes[6] &= 0x0f
    bytes[6] |= 0x50

    # variant is DCE 1.1
    bytes[8] &= 0x3f
    bytes[8] |= 0x80

    bytes = [4, 2, 2, 2, 6].map do |i|
      bytes.slice!(0, i).pack('C*').unpack('H*')
    end

    bytes.join('-')
  end

  def name_uuid(*args)
    self.class.name_uuid(*args)
  end

  def check_theme_exists(theme, res)
    return true if theme == 'keycloak'
    return true if theme == 'keycloak.v2'

    install_dir = self.class.install_dir || '/opt/keycloak'
    path = File.join(install_dir, 'themes', theme)
    return if File.exist?(path)

    Puppet.warning("#{res}: Theme #{theme} not found at path #{path}.")
  end
end
