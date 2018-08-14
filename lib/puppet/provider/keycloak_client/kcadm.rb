require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_client).provide(:kcadm, :parent => Puppet::Provider::Keycloak_API) do
  desc ""

  mk_resource_methods

  def self.instances
    clients = []

    realms = get_realms()

    realms.each do |realm|
      output = kcadm('get', 'clients', realm)
      Puppet.debug("#{realm} clients: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError => e
        Puppet.debug('Unable to parse output from kcadm get clients')
        data = []
      end

      data.each do |d|
        # avoid built-in clients
        if d.key?('clientAuthenticatorType') &&
           d['clientAuthenticatorType'] == 'client-secret' &&
           ! d.key?('name')
          begin
            secret_output = kcadm('get', "clients/#{d['id']}/client-secret", realm)
          rescue
            Puppet.debug("Unable to get clients/#{d['id']}/client-secret")
            secret_output = "{}"
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
          next unless d.key?(camelize(property))
          value = d[camelize(property)]
          if property == :secret
            value = secret
          end
          if !!value == value
            value = value.to_s.to_sym
          end
          client[property.to_sym] = value
        end
        clients << new(client)
      end
    end
    clients
  end

  def self.prefetch(resources)
    clients = instances
    resources.keys.each do |name|
      if provider = clients.find { |c| c.client_id == resources[name][:client_id] && c.realm == resources[name][:realm] }
        resources[name].provider = provider
      end
    end
  end

  def get_scope_map
    scope_map = {}
    output = kcadm('get', 'client-scopes', resource[:realm], nil, ['id','name'])
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from kcadm get client-scopes')
      return {}
    end
    data.each do |d|
      scope_map[d['name']] = d['id']
    end
    scope_map
  end

  def create
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    data = {}
    data[:id] = resource[:id]
    data[:clientId] = resource[:client_id]
    data[:secret] = resource[:secret] if resource[:secret]
    type_properties.each do |property|
      next if [:default_client_scopes, :optional_client_scopes].include?(property)
      if resource[property.to_sym]
        data[camelize(property)] = convert_property_value(resource[property.to_sym])
      end
    end

    t = Tempfile.new('keycloak_client')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      output = kcadm('create', 'clients', resource[:realm], t.path)
      Puppet.debug("create client output: #{output}")
    rescue Exception => e
      raise Puppet::Error, "kcadm create client failed\nError message: #{e.message}"
    end
    if resource[:default_client_scopes] or resource[:optional_client_scopes]
      client = JSON.parse(output)
      scope_map = get_scope_map
      scope_id = nil
    end
    if resource[:default_client_scopes]
      remove_default_scopes = client['defaultClientScopes'] - resource[:default_client_scopes]
      begin
        remove_default_scopes.each do |s|
          scope_id = scope_map[s]
          output = kcadm('delete', "clients/#{resource[:id]}/default-client-scopes/#{scope_id}", resource[:realm])
        end
      rescue Exception => e
        raise Puppet::Error, "kcadm delete clients/#{resource[:id]}/default-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:optional_client_scopes]
      remove_optional_scopes = client['optionalClientScopes'] - resource[:optional_client_scopes]
      begin
        remove_optional_scopes.each do |s|
          scope_id = scope_map[s]
          output = kcadm('delete', "clients/#{resource[:id]}/optional-client-scopes/#{scope_id}", resource[:realm])
        end
      rescue Exception => e
        raise Puppet::Error, "kcadm delete clients/#{resource[:id]}/optional-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:default_client_scopes]
      add_default_scopes = resource[:default_client_scopes] - client['defaultClientScopes']
      begin
        add_default_scopes.each do |s|
          scope_id = scope_map[s]
          output = kcadm('update', "clients/#{resource[:id]}/default-client-scopes/#{scope_id}", resource[:realm])
        end
      rescue Exception => e
        raise Puppet::Error, "kcadm update clients/#{resource[:id]}/default-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:optional_client_scopes]
      add_optional_scopes = resource[:optional_client_scopes] - client['optionalClientScopes']
      begin
        add_optional_scopes.each do |s|
          scope_id = scope_map[s]
          output = kcadm('update', "clients/#{resource[:id]}/optional-client-scopes/#{scope_id}", resource[:realm])
        end
      rescue Exception => e
        raise Puppet::Error, "kcadm update clients/#{resource[:id]}/optional-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    begin
      kcadm('delete', "clients/#{resource[:id]}", resource[:realm])
    rescue Exception => e
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
    if not @property_flush.empty?
      fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

      data = {}
      data[:clientId] = resource[:client_id]
      type_properties.each do |property|
        next if [:default_client_scopes, :optional_client_scopes].include?(property)
        if @property_flush[property.to_sym]
          data[camelize(property)] = convert_property_value(resource[property.to_sym])
        end
      end

      # Only update if more than clientId set
      if data.keys().size > 1
        t = Tempfile.new('keycloak_client')
        t.write(JSON.pretty_generate(data))
        t.close
        Puppet.debug(IO.read(t.path))
        begin
          kcadm('update', "clients/#{resource[:id]}", resource[:realm], t.path)
        rescue Exception => e
          raise Puppet::Error, "kcadm update client failed\nError message: #{e.message}"
        end
      end
      if @property_flush[:default_client_scopes] or @property_flush[:optional_client_scopes]
        scope_map = get_scope_map
        scope_id = nil
      end
      if @property_flush[:default_client_scopes]
        remove_default_scopes = @property_hash[:default_client_scopes] - @property_flush[:default_client_scopes]
        begin
          remove_default_scopes.each do |s|
            scope_id = scope_map[s]
            output = kcadm('delete', "clients/#{resource[:id]}/default-client-scopes/#{scope_id}", resource[:realm])
          end
        rescue Exception => e
          raise Puppet::Error, "kcadm delete clients/#{resource[:id]}/default-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:optional_client_scopes]
        remove_optional_scopes = @property_hash[:optional_client_scopes] - @property_flush[:optional_client_scopes]
        begin
          remove_optional_scopes.each do |s|
            scope_id = scope_map[s]
            output = kcadm('delete', "clients/#{resource[:id]}/optional-client-scopes/#{scope_id}", resource[:realm])
          end
        rescue Exception => e
          raise Puppet::Error, "kcadm delete clients/#{resource[:id]}/optional-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:default_client_scopes]
        add_default_scopes = @property_flush[:default_client_scopes] - @property_hash[:default_client_scopes]
        begin
          add_default_scopes.each do |s|
            scope_id = scope_map[s]
            output = kcadm('update', "clients/#{resource[:id]}/default-client-scopes/#{scope_id}", resource[:realm])
          end
        rescue Exception => e
          raise Puppet::Error, "kcadm update clients/#{resource[:id]}/default-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:optional_client_scopes]
        add_optional_scopes = @property_flush[:optional_client_scopes] - @property_hash[:optional_client_scopes]
        begin
          add_optional_scopes.each do |s|
            scope_id = scope_map[s]
            output = kcadm('update', "clients/#{resource[:id]}/optional-client-scopes/#{scope_id}", resource[:realm])
          end
        rescue Exception => e
          raise Puppet::Error, "kcadm update clients/#{resource[:id]}/optional-client-scopes/#{scope_id}: #{e.message}"
        end
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end

end
