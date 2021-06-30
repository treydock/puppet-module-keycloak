require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_role_mapping).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  def opt
    (resource[:group] == :true) ? 'gname' : 'uusername'
  end

  def realm_roles
    @active_realm_roles = []

    output = kcadm('get-roles', nil, resource[:realm], nil, nil, false, opt => resource[:name])
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug('Unable to parse output from kcadm get-roles')
    end

    data.each do |d|
      @active_realm_roles << d['name']
    end
    @active_realm_roles
  end

  def realm_roles=(_value)
    removed_roles = @active_realm_roles.reject { |role| resource[:realm_roles].include?(role) }
    remove_roles(removed_roles)

    new_roles = resource[:realm_roles].reject { |role| @active_realm_roles.include?(role) }
    add_roles(new_roles)
  end

  def client_roles
    @clients = []
    @active_client_roles = {}

    # Get a unique list of clients referred to in client role mappings for this
    # user or group
    resource[:client_roles].keys.each do |cclientid|
      output = kcadm('get-roles', nil, resource[:realm], nil, nil, false, opt => resource[:name], 'cclientid' => cclientid)
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get-roles')
      end
      @active_client_roles[cclientid] = [] unless @active_client_roles.has_key?(cclientid)
      data.each do |role|
        @active_client_roles[cclientid] << role['name']
      end
      p @active_client_roles
    end

    @active_client_roles
  end

  def client_roles=(_value)
    #kcadm.sh add-roles -r demorealm --gname Group --cclientid realm-management --rolename create-client --rolename view-users

  end

  def remove_roles(roles)
    return if roles.empty?
    kcadm('remove-roles', '', resource[:realm], nil, nil, false, opt => resource[:name], rolename: roles)
  end

  def add_roles(roles)
    return if roles.empty?
    kcadm('add-roles', '', resource[:realm], nil, nil, false, opt => resource[:name], rolename: roles)
  end
end
