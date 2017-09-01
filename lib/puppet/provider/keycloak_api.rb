require 'puppet'
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

class Puppet::Provider::Keycloak_API < Puppet::Provider

  @install_base = '/opt/keycloak'
  @server = 'http://localhost:8080/auth'
  @realm = 'master'
  @user = 'admin'
  @password = 'changeme'

  class << self
    attr_accessor :install_base
    attr_accessor :server
    attr_accessor :realm
    attr_accessor :user
    attr_accessor :password
  end

  initvars

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
    kcadm_path = File.join(self.install_base, 'bin/kcadm-wrapper.sh')
    # Auth arguments unused as defined in kcadm-wrapper.sh
    auth_arguments = [
      '--no-config',
      '--server', self.server,
      '--realm', self.realm,
      '--user', self.user,
      '--password', self.password,
    ]
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
    cmd = [kcadm_path] + arguments
#    cmd = [kcadm_path] + arguments + auth_arguments

    #t = Tempfile.new('kcadm_password')
    #t.write(self.password)
    #t.close
    #execute(cmd, :stdinfile => t.path.to_s)
    execute(cmd, :combine => false)
  end
  def kcadm(*args)
    self.class.kcadm(*args)
  end

  def self.get_realms(fields = nil)
    output = kcadm('get', 'realms', nil, nil, fields = ['realm'])
    data = JSON.parse(output)
    realms = data.map { |r| r['realm'] }
    return realms
  end

end
