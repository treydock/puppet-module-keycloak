require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_role_mapping).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  def opt
    (resource[:group] == :true) ? 'gname' : 'uusername'
  end

  def realm_roles
    active_realm_roles = []

    output = kcadm('get-roles', nil, resource[:realm], nil, nil, false, opt => resource[:name])
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug('Unable to parse output from kcadm get-roles')
    end

    data.each do |d|
      active_realm_roles << d['name']
    end
    active_realm_roles
  end

  def realm_roles=(_value)
    removed_roles = realm_roles.reject { |role| resource[:realm_roles].include?(role) }
    remove_roles(removed_roles)

    new_roles = resource[:realm_roles].reject { |role| realm_roles.include?(role) }
    add_roles(new_roles)
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
