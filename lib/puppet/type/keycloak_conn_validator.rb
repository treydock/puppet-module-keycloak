Puppet::Type.newtype(:keycloak_conn_validator) do

  @doc = "Verify that a connection can be successfully established between a node
          and the keycloak server.  Its primary use is as a precondition to
          prevent configuration changes from being applied if the keycloak
          server cannot be reached, but it could potentially be used for other
          purposes such as monitoring."

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:keycloak_server) do
    desc 'The DNS name or IP address of the server where keycloak should be running.'
    defaultto 'localhost'
  end

  newparam(:keycloak_port) do
    desc 'The port that the keycloak server should be listening on.'
    defaultto '8080'
  end

  newparam(:use_ssl) do
    desc 'Whether the connection will be attemped using https'
    defaultto false
  end

  newparam(:test_url) do
    desc 'URL to use for testing if the Keycloak database is up'
    defaultto '/auth/admin/serverinfo'
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
end
