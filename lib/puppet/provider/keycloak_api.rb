require 'puppet'
require 'json'

class Puppet::Provider::Keycloak_API < Puppet::Provider

  initvars

  # Unused but defined anyways
  commands :kcadm_wrapper => '/opt/keycloak/bin/kcadm-wrapper.sh'

  @install_base = nil
  @server = nil
  @realm = nil
  @user = nil
  @password = nil
  @use_wrapper = true

  class << self
    attr_accessor :install_base
    attr_accessor :server
    attr_accessor :realm
    attr_accessor :user
    attr_accessor :password
    attr_accessor :use_wrapper
  end

  def self.type_properties
    resource_type.validproperties.reject { |p| p.to_sym == :ensure }
  end
  def type_properties
    self.class.type_properties
  end

  def self.camelize(value)
    str = value.to_s.split('_').collect(&:capitalize).join
    str[0].downcase + str[1..-1]
  end
  def camelize(*args)
    self.class.camelize(*args)
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

  def self.kcadm(action, resource, realm = nil, file = nil, fields = nil)
    kcadm_wrapper = '/opt/keycloak/bin/kcadm-wrapper.sh'

    arguments = [ action, resource ]
    if realm
      arguments << '-r'
      arguments << realm
    end
    if file
      arguments << '-f'
      arguments << file
    end
    if fields
      arguments << '--fields'
      arguments << fields.join(',')
    end
    if self.use_wrapper == false || self.use_wrapper == :false
      auth_arguments = [
        '--no-config',
        '--server', self.server,
        '--realm', self.realm,
        '--user', self.user,
        '--password', self.password,
      ]
      cmd = [File.join(self.install_base, 'bin/kcadm.sh')] + arguments + auth_arguments
    else
      cmd = [kcadm_wrapper] + arguments
    end

    execute(cmd, :combine => false, :failonfail => true)
  end
  def kcadm(*args)
    self.class.kcadm(*args)
  end

  def self.get_realms()
    output = kcadm('get', 'realms', nil, nil, ['realm'])
    data = JSON.parse(output)
    realms = data.map { |r| r['realm'] }
    return realms
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
      0xc8
    ].map {|b| b.chr}.join

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

    bytes = [4, 2, 2, 2, 6].collect do |i|
      bytes.slice!(0, i).pack('C*').unpack('H*')
    end

    bytes.join('-')
  end
  def name_uuid(*args)
    self.class.name_uuid(*args)
  end

end
