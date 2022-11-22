# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_resource_validator).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc "A provider for the resource type `keycloak_resource_validator`,
        which validates a Keycloak resource exists."

  # Test to see if the resource exists, returns true if it does, false if it
  # does not.
  #
  # Here we simply monopolize the resource API, to execute a test to see if the
  # database is connectable. When we return a state of `false` it triggers the
  # create method where we can return an error message.
  #
  # @return [bool] did the test succeed?
  def exists?
    start_time = Time.now
    timeout = resource[:timeout]

    success = validator

    while success == false && ((Time.now - start_time) < timeout)
      # It can take several seconds for the keycloak server to start up;
      # especially on the first install.  Therefore, our first connection attempt
      # may fail.  Here we have somewhat arbitrarily chosen to retry every 2
      # seconds until the configurable timeout has expired.
      Puppet.notice("Failed to find resource #{resource[:test_key]}=#{resource[:test_value]} at #{resource[:test_url]}; sleeping 2 seconds before retry")
      sleep 2
      success = validator
    end

    unless success
      Puppet.notice("Failed to find resource #{resource[:test_key]}=#{resource[:test_value]} at #{resource[:test_url]} within timeout window of #{timeout} seconds; giving up.")
    end

    success
  end

  # This method is called when the exists? method returns false.
  #
  # @return [void]
  def create
    # If `#create` is called, that means that `#exists?` returned false, which
    # means that the connection could not be established... so we need to
    # cause a failure here.
    raise Puppet::Error, "Unable to find resource #{resource[:test_key]}=#{resource[:test_value]} at #{resource[:test_url]}"
  end

  def test_realms
    return @test_realms if @test_realms

    @test_realms = if resource[:realm]
                     [resource[:realm]]
                   else
                     realms
                   end
  end

  # Returns the existing validator, if one exists otherwise creates a new object
  # from the class.
  #
  # @api private
  def validator
    test_realms.each do |realm|
      output = kcadm('get', resource[:test_url], realm)
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get resource')
        next
      end
      data.each do |d|
        d.each_pair do |k, v|
          next unless k == resource[:test_key].to_s
          return true if v == resource[:test_value].to_s
        end
      end
    end
    false
  end
end
