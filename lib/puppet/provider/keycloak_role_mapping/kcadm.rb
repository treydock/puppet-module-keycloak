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

  def mapping(realm, group)
    if group
      path = 'groups'
      prop = 'name'
    else
      path = 'users'
      prop = 'username'
    end

    output = kcadm('get', path, realm)
    Puppet.debug("#{resource[:realm]} #{path} #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug("Unable to parse output from kcadm get #{path}")
      data = []
    end
    data
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

    #return if client_roles.empty?
    p id(resource[:group])



    #resource[:name]
    #    output = kcadm('get', "users/#{u['id']}/role-mappings", realm)
    #    begin
    #      role_mappings_data = JSON.parse(output)
    #    rescue JSON::ParserError
    #      Puppet.debug("Unable to parse output from kcadm get users/#{u['id']}/role-mappings")
    #      role_mappings_data = []
    #    end
    #    if role_mappings_data.has_key?('realmMappings')
    #      role_mapping = {}
    #      role_mappings_data['realmMappings'].each do |m|
    #        role_mapping[:ensure] = :present
    #        role_mapping[:realm] = realm
    #        role_mapping[:name] = "#{m['name']} to #{u['username']} on #{realm}"
    #        role_mapping[:user] = u['username']
    #        role_mapping[:user_id] = u['id']
    #        role_mapping[:role] = m['name']
    #        role_mapping[:role_id] = m['id']
    #        role_mappings << new(role_mapping)
    #      end
    #    end
    #  end
    #end

    # FIXME: we should get the _active_ client roles for this user, not the ones
    # from the catalog.

    # Get a unique list of clients referred to in client role mappings for this
    # user or group
    #resource[:client_roles].keys.each do |cclientid|
    #  output = kcadm('get-roles', nil, resource[:realm], nil, nil, false, opt => resource[:name], 'cclientid' => cclientid)
    #  begin
    #    data = JSON.parse(output)
    #  rescue JSON::ParserError
    #    Puppet.debug('Unable to parse output from kcadm get-roles')
    #  end
    #  @active_client_roles[cclientid] = [] unless @active_client_roles.has_key?(cclientid)
    #  data.each do |role|
    #    @active_client_roles[cclientid] << role['name']
    #  end
    #end

    #@active_client_roles
  end

  def client_roles=(_value)
  #  return
  #  p "Current:"
  #  p @active_client_roles
  #  p "Desired:"
  #  p resource[:client_roles]

  #  # Removed clients
  #  (@active_client_roles.keys - resource[:client_roles].keys).each do |cclientid|
  #    puts "Would remove #{@active_client_roles[cclientid]} from empty client #{cclientid}"
  #  end
  #  
  #  resource[:client_roles].each do |cclientid, desired_roles|
  #    # New clients
  #    if @active_client_roles[cclientid].nil?
  #      puts "Would add #{desired_roles} to client #{cclientid}"
  #    else
  #      # Removed client roles for this client
  #      removed_roles = @active_client_roles[cclientid].select { |role| resource[:client_roles][cclientid].include?(role) }
  #      p removed_roles
  #      unless removed_roles.empty?
  #        puts "Would remove #{removed_roles} from client #{cclientid}"
  #      end
  #  
  #      # New client roles for this client
  #      new_roles = resource[:client_roles][cclientid].reject { |role| @active_client_roles[cclientid].include?(role) }
  #      unless new_roles.empty?
  #        puts "Would add #{new_roles} to client role #{cclientid}"
  #      end
  #    end
  #  end

    #@active_client_roles
    
    #removed_roles = @active_client_roles.reject { |role| resource[:realm_roles].include?(role) }

    #remove_roles(removed_roles)

    #new_roles = resource[:realm_roles].reject { |role| @active_realm_roles.include?(role) }
    #add_roles(new_roles)

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
