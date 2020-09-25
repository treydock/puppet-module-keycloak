require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_client).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def attributes_properties
    [
      :login_theme,
      :access_token_lifespan,
    ]
  end

  def dot_attributes_properties
    [
      :access_token_lifespan,
    ]
  end

  def self.auth_flow_properties
    {
      browser_flow: 'browser',
      direct_grant_flow: 'direct_grant',
    }
  end

  def auth_flow_properties
    self.class.auth_flow_properties
  end

  def attribute_key(property)
    if dot_attributes_properties.include?(property)
      property.to_s.tr('_', '.')
    else
      property
    end
  end

  def self.instances
    clients = []
    realms.each do |realm|
      output = kcadm('get', 'clients', realm)
      Puppet.debug("#{realm} clients: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get clients')
        data = []
      end

      data.each do |d|
        # avoid built-in clients
        if d.key?('clientAuthenticatorType') &&
           d['clientAuthenticatorType'] == 'client-secret' &&
           !d.key?('name')
          begin
            secret_output = kcadm('get', "clients/#{d['id']}/client-secret", realm)
          rescue
            Puppet.debug("Unable to get clients/#{d['id']}/client-secret")
            secret_output = '{}'
          end
          secret_data = JSON.parse(secret_output)
          secret = secret_data['value']
        else
          secret = nil
        end
        client = {}
        client[:ensure] = :present
        client[:id] = d['id']
        client[:client_id] = d['clientId']
        client[:realm] = realm
        client[:name] = "#{client[:client_id]} on #{client[:realm]}"
        type_properties.each do |property|
          camel_key = camelize(property)
          dot_key = property.to_s.tr('_', '.')
          key = property.to_s
          attributes = d['attributes'] || {}
          auth_flows = d['authenticationFlowBindingOverrides'] || {}
          if property == :secret
            value = secret
          elsif d.key?(camel_key)
            value = d[camel_key]
          elsif attributes.key?(dot_key)
            value = attributes[dot_key]
          elsif attributes.key?(key)
            value = attributes[key]
          elsif auth_flows.key?(auth_flow_properties[property])
            flow_alias = flow_ids(realm)[auth_flows[auth_flow_properties[property]]]
            value = flow_alias
          end
          if !!value == value # rubocop:disable Style/DoubleNegation
            value = value.to_s.to_sym
          end
          client[property.to_sym] = value
        end
        # The absence of a value should be 'absent'
        client[:login_theme] = 'absent' if client[:login_theme].nil?
        clients << new(client)
      end
    end
    clients
  end

  def self.prefetch(resources)
    clients = instances
    resources.keys.each do |name|
      provider = clients.find { |c| c.client_id == resources[name][:client_id] && c.realm == resources[name][:realm] }
      if provider
        resources[name].provider = provider
      end
    end
  end

  def scope_map
    return @scope_map if @scope_map
    output = kcadm('get', 'client-scopes', resource[:realm], nil, ['id', 'name'])
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug('Unable to parse output from kcadm get client-scopes')
      return {}
    end
    @scope_map = {}
    data.each do |d|
      @scope_map[d['name']] = d['id']
    end
    @scope_map
  end

  def self.flow_ids(realm)
    @flow_ids = {} unless @flow_ids
    return @flow_ids[realm] if @flow_ids[realm]
    output = kcadm('get', 'authentication/flows', realm, nil, ['id', 'alias'])
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug('Unable to parse output from kcadm get authentication/flows')
      return {}
    end
    @flow_ids[realm] = {}
    data.each do |d|
      @flow_ids[realm][d['alias']] = d['id']
      @flow_ids[realm][d['id']] = d['alias']
    end
    @flow_ids[realm]
  end

  def flow_ids
    @flow_ids = {} unless @flow_ids
    return @flow_ids unless @flow_ids.empty?
    self.class.instance_variable_set(:@flow_ids, nil)
    @flow_ids = self.class.flow_ids(resource[:realm])
    @flow_ids
  end

  def create
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    data = {}
    data[:id] = resource[:id]
    data[:clientId] = resource[:client_id]
    data[:secret] = resource[:secret] if resource[:secret]
    type_properties.each do |property|
      next if [:default_client_scopes, :optional_client_scopes].include?(property)
      next unless resource[property.to_sym]
      value = convert_property_value(resource[property.to_sym])
      next if value == 'absent' || value == :absent || value.nil?
      if attributes_properties.include?(property)
        unless data.key?(:attributes)
          data[:attributes] = {}
        end
        data[:attributes][attribute_key(property)] = value
      elsif auth_flow_properties.include?(property)
        unless data.key?(:authenticationFlowBindingOverrides)
          data[:authenticationFlowBindingOverrides] = {}
        end
        flow_id = flow_ids[value]
        data[:authenticationFlowBindingOverrides][auth_flow_properties[property]] = flow_id
      else
        data[camelize(property)] = value
      end
    end

    t = Tempfile.new('keycloak_client')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      if resource[:login_theme]
        check_theme_exists(resource[:login_theme], "Keycloak_client[#{resource[:name]}]")
      end
      output = kcadm('create', 'clients', resource[:realm], t.path)
      Puppet.debug("create client output: #{output}")
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm create client failed\nError message: #{e.message}"
    end
    if resource[:default_client_scopes] || resource[:optional_client_scopes]
      client = JSON.parse(output)
      scope_id = nil
    end
    if resource[:default_client_scopes]
      remove_default_scopes = client['defaultClientScopes'] - resource[:default_client_scopes]
      begin
        remove_default_scopes.each do |s|
          scope_id = scope_map[s]
          kcadm('delete', "clients/#{resource[:id]}/default-client-scopes/#{scope_id}", resource[:realm])
        end
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm delete clients/#{resource[:id]}/default-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:optional_client_scopes]
      remove_optional_scopes = client['optionalClientScopes'] - resource[:optional_client_scopes]
      begin
        remove_optional_scopes.each do |s|
          scope_id = scope_map[s]
          kcadm('delete', "clients/#{resource[:id]}/optional-client-scopes/#{scope_id}", resource[:realm])
        end
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm delete clients/#{resource[:id]}/optional-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:default_client_scopes]
      add_default_scopes = resource[:default_client_scopes] - client['defaultClientScopes']
      begin
        add_default_scopes.each do |s|
          scope_id = scope_map[s]
          kcadm('update', "clients/#{resource[:id]}/default-client-scopes/#{scope_id}", resource[:realm])
        end
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update clients/#{resource[:id]}/default-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:optional_client_scopes]
      add_optional_scopes = resource[:optional_client_scopes] - client['optionalClientScopes']
      begin
        add_optional_scopes.each do |s|
          scope_id = scope_map[s]
          kcadm('update', "clients/#{resource[:id]}/optional-client-scopes/#{scope_id}", resource[:realm])
        end
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update clients/#{resource[:id]}/optional-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    begin
      kcadm('delete', "clients/#{id}", resource[:realm])
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm delete realm failed\nError message: #{e.message}"
    end

    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  type_properties.each do |prop|
    define_method "#{prop}=".to_sym do |value|
      @property_flush[prop] = value
    end
  end

  def flush
    unless @property_flush.empty?
      raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

      data = {}
      data[:clientId] = resource[:client_id]
      data[:authenticationFlowBindingOverrides] = {}
      type_properties.each do |property|
        next if [:default_client_scopes, :optional_client_scopes].include?(property)
        next unless @property_flush[property.to_sym]
        value = convert_property_value(@property_flush[property.to_sym])
        value = nil if value.to_s == 'absent'
        if attributes_properties.include?(property)
          unless data.key?(:attributes)
            data[:attributes] = {}
          end
          data[:attributes][attribute_key(property)] = value
        elsif auth_flow_properties.include?(property)
          flow_id = value.nil? ? nil : flow_ids[value]
          data[:authenticationFlowBindingOverrides][auth_flow_properties[property]] = flow_id
        else
          data[camelize(property)] = value
        end
      end

      # Keycload API requires "serviceAccountsEnabled": true to be present in
      # the JSON when "authorizationServicesEnabled": true
      if data['authorizationServicesEnabled'] && data['serviceAccountsEnabled'].nil?
        data[:serviceAccountsEnabled] = true
      end

      # Only update if more than clientId set
      if data.keys.size > 1
        t = Tempfile.new('keycloak_client')
        t.write(JSON.pretty_generate(data))
        t.close
        Puppet.debug(IO.read(t.path))
        begin
          if @property_flush[:login_theme]
            check_theme_exists(@property_flush[:login_theme], "Keycloak_client[#{resource[:name]}]")
          end
          kcadm('update', "clients/#{id}", resource[:realm], t.path)
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update client failed\nError message: #{e.message}"
        end
      end
      if @property_flush[:default_client_scopes] || @property_flush[:optional_client_scopes]
        scope_id = nil
      end
      if @property_flush[:default_client_scopes]
        remove_default_scopes = @property_hash[:default_client_scopes] - @property_flush[:default_client_scopes]
        begin
          remove_default_scopes.each do |s|
            scope_id = scope_map[s]
            kcadm('delete', "clients/#{id}/default-client-scopes/#{scope_id}", resource[:realm])
          end
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm delete clients/#{id}/default-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:optional_client_scopes]
        remove_optional_scopes = @property_hash[:optional_client_scopes] - @property_flush[:optional_client_scopes]
        begin
          remove_optional_scopes.each do |s|
            scope_id = scope_map[s]
            kcadm('delete', "clients/#{id}/optional-client-scopes/#{scope_id}", resource[:realm])
          end
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm delete clients/#{id}/optional-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:default_client_scopes]
        add_default_scopes = @property_flush[:default_client_scopes] - @property_hash[:default_client_scopes]
        begin
          add_default_scopes.each do |s|
            scope_id = scope_map[s]
            kcadm('update', "clients/#{id}/default-client-scopes/#{scope_id}", resource[:realm])
          end
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update clients/#{id}/default-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:optional_client_scopes]
        add_optional_scopes = @property_flush[:optional_client_scopes] - @property_hash[:optional_client_scopes]
        begin
          add_optional_scopes.each do |s|
            scope_id = scope_map[s]
            kcadm('update', "clients/#{id}/optional-client-scopes/#{scope_id}", resource[:realm])
          end
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update clients/#{id}/optional-client-scopes/#{scope_id}: #{e.message}"
        end
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
