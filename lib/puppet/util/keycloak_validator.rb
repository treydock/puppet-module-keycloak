# frozen_string_literal: true

require 'net/http'

# Validator class, for testing that Keycloak is alive
class Puppet::Util::KeycloakValidator
  attr_reader :keycloak_server, :keycloak_port, :use_ssl, :test_path, :relative_path, :path

  def initialize(keycloak_server, keycloak_port, use_ssl = false, test_path = '/realms/master/.well-known/openid-configuration', relative_path = '/')
    @keycloak_server = keycloak_server
    @keycloak_port   = keycloak_port
    @use_ssl         = use_ssl
    @test_path       = test_path
    @relative_path   = relative_path
    @path = if @relative_path == '/'
              @test_path
            else
              "#{@relative_path}#{@test_path}"
            end
  end

  # Utility method; attempts to make an http/https connection to the keycloak server.
  # This is abstracted out into a method so that it can be called multiple times
  # for retry attempts.
  #
  # @return true if the connection is successful, false otherwise.
  def attempt_connection
    # All that we care about is that we are able to connect successfully via
    # http(s), so here we're simpling hitting a somewhat arbitrary low-impact URL
    # on the keycloak server.
    http = Net::HTTP.new(@keycloak_server, @keycloak_port)
    http.use_ssl = @use_ssl
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(@path)
    request.add_field('Accept', 'application/json')
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPUnauthorized)
      Puppet.notice "Unable to connect to keycloak server (http#{use_ssl ? 's' : ''}://#{keycloak_server}:#{keycloak_port}#{path}): [#{response.code}] #{response.msg}"
      return false
    end
    true
  rescue Exception => e # rubocop:disable Lint/RescueException
    Puppet.notice "Unable to connect to keycloak server (http#{use_ssl ? 's' : ''}://#{keycloak_server}:#{keycloak_port}#{path}): #{e.message}"
    false
  end
end
