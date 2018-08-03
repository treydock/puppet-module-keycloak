require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_realm).provide(:kcadm, :parent => Puppet::Provider::Keycloak_API) do
  desc ""

  mk_resource_methods

  def self.get_client_scopes(realm, type)
    output = kcadm('get', "realms/#{realm}/default-#{type}-client-scopes")
    Puppet.debug("Realms #{realm} #{type} client scopes: #{output}")
    data = JSON.parse(output)
    scopes = {}
    data.each do |d|
      scopes[d['name']] = d['id']
    end
    Puppet.debug("Returned scopes: #{scopes}")
    scopes
  end
  def get_client_scopes(*args)
    self.class.get_client_scopes(*args)
  end

  def self.instances
    realms = []

    output = kcadm('get', 'realms')
    Puppet.debug("Realms: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from kcadm get realms')
      data = []
    end
    data.collect do |d|
      realm = {}
      realm[:ensure] = :present
      realm[:id] = d['id']
      realm[:name] = d['realm']
      type_properties.each do |property|
        next if [:default_client_scopes, :optional_client_scopes].include?(property)
        value = d[camelize(property)]
        if !!value == value
          value = value.to_s.to_sym
        end
        realm[property.to_sym] = value
      end
      default_scopes = get_client_scopes(realm[:name], 'default')
      realm[:default_client_scopes] = default_scopes.keys().map { |k| k.to_s }
      optional_scopes = get_client_scopes(realm[:name], 'optional')
      realm[:optional_client_scopes] = optional_scopes.keys().map { |k| k.to_s }
      new(realm)
    end
  end

  def self.prefetch(resources)
    realms = instances
    resources.keys.each do |name|
      if provider = realms.find { |realm| realm.name == name }
        resources[name].provider = provider
      end
    end
  end

  def create
    data = {}
    data[:id] = resource[:id]
    data[:realm] = resource[:name]
    type_properties.each do |property|
      next if [:default_client_scopes, :optional_client_scopes].include?(property)
      if resource[property.to_sym]
        data[camelize(property)] = convert_property_value(resource[property.to_sym])
      end
    end

    t = Tempfile.new('keycloak_realm')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', 'realms', nil, t.path)
    rescue Exception => e
      raise Puppet::Error, "kcadm create realm failed\nError message: #{e.message}"
    end
    scope_id = nil
    if resource[:default_client_scopes]
      default_scopes = default_scopes ||= get_client_scopes(resource[:name], 'default')
      remove_default_scopes = default_scopes.keys() - resource[:default_client_scopes]
      begin
        remove_default_scopes.each do |s|
          scope_id = default_scopes[s]
          output = kcadm('delete', "realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}")
        end
      rescue Exception => e
        raise Puppet::Error, "kcadm delete realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:optional_client_scopes]
      optional_scopes = optional_scopes ||= get_client_scopes(resource[:name], 'optional')
      remove_optional_scopes = optional_scopes.keys() - resource[:optional_client_scopes]
      begin
        remove_optional_scopes.each do |s|
          scope_id = optional_scopes[s]
          output = kcadm('delete', "realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}")
        end
      rescue Exception => e
        raise Puppet::Error, "kcadm delete realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:default_client_scopes]
      default_scopes = default_scopes ||= get_client_scopes(resource[:name], 'default')
      add_default_scopes = resource[:default_client_scopes] - default_scopes.keys()
      begin
        add_default_scopes.each do |s|
          scope_id = default_scopes[s]
          output = kcadm('update', "realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}")
        end
      rescue Exception => e
        raise Puppet::Error, "kcadm update realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:optional_client_scopes]
      optional_scopes = optional_scopes ||= get_client_scopes(resource[:name], 'optional')
      add_optional_scopes = resource[:optional_client_scopes] - optional_scopes.keys()
      begin
        add_optional_scopes.each do |s|
          scope_id = optional_scopes[s]
          output = kcadm('update', "realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}")
        end
      rescue Exception => e
        raise Puppet::Error, "kcadm update realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    begin
      kcadm('delete', "realms/#{resource[:name]}")
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
      data = {}
      type_properties.each do |property|
        next if [:default_client_scopes, :optional_client_scopes].include?(property)
        if @property_flush[property.to_sym] # || resource[property.to_sym]
          data[camelize(property)] = convert_property_value(resource[property.to_sym])
        end
      end

      if ! data.empty?
        t = Tempfile.new('keycloak_realm')
        t.write(JSON.pretty_generate(data))
        t.close
        Puppet.debug(IO.read(t.path))
        begin
          kcadm('update', "realms/#{resource[:name]}", nil, t.path)
        rescue Exception => e
          raise Puppet::Error, "kcadm update realm failed\nError message: #{e.message}"
        end
      end
      scope_id = nil
      if @property_flush[:default_client_scopes]
        default_scopes = default_scopes ||= get_client_scopes(resource[:name], 'default')
        remove_default_scopes = default_scopes.keys() - @property_flush[:default_client_scopes]
        begin
          remove_default_scopes.each do |s|
            scope_id = default_scopes[s]
            output = kcadm('delete', "realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}")
          end
        rescue Exception => e
          raise Puppet::Error, "kcadm delete realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:optional_client_scopes]
        optional_scopes = optional_scopes ||= get_client_scopes(resource[:name], 'optional')
        remove_optional_scopes = optional_scopes.keys() - @property_flush[:optional_client_scopes]
        begin
          remove_optional_scopes.each do |s|
            scope_id = optional_scopes[s]
            output = kcadm('delete', "realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}")
          end
        rescue Exception => e
          raise Puppet::Error, "kcadm delete realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:default_client_scopes]
        default_scopes = default_scopes ||= get_client_scopes(resource[:name], 'default')
        add_default_scopes = @property_flush[:default_client_scopes] - default_scopes.keys()
        begin
          add_default_scopes.each do |s|
            scope_id = default_scopes[s]
            output = kcadm('update', "realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}")
          end
        rescue Exception => e
          raise Puppet::Error, "kcadm update realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:optional_client_scopes]
        optional_scopes = optional_scopes ||= get_client_scopes(resource[:name], 'optional')
        add_optional_scopes = @property_flush[:optional_client_scopes] - optional_scopes.keys()
        begin
          add_optional_scopes.each do |s|
            scope_id = optional_scopes[s]
            output = kcadm('update', "realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}")
          end
        rescue Exception => e
          raise Puppet::Error, "kcadm update realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}: #{e.message}"
        end
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end

end
