require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_realm).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def flow_properties
    [
      :browser_flow,
      :registration_flow,
      :direct_grant_flow,
      :reset_credentials_flow,
      :client_authentication_flow,
      :docker_authentication_flow,
    ]
  end

  def self.smtp_server_properties
    [
      :smtp_server_user,
      :smtp_server_password,
      :smtp_server_host,
      :smtp_server_port,
      :smtp_server_auth,
      :smtp_server_starttls,
      :smtp_server_ssl,
      :smtp_server_envelope_from,
      :smtp_server_from,
      :smtp_server_from_display_name,
      :smtp_server_reply_to,
      :smtp_server_reply_to_display_name,
    ]
  end

  def self.browser_security_headers
    [
      :content_security_policy,
    ]
  end

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

  def self.get_events_config(realm)
    output = kcadm('get', 'events/config', realm)
    Puppet.debug("#{realm} events/config: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug('Unable to parse output from kcadm get events/config')
      data = {}
    end
    data.delete('enabledEventTypes')
    data
  end

  def available_flows(realm)
    output = kcadm('get', 'authentication/flows', realm, nil, ['alias'])
    Puppet.debug("#{realm} authentication/flows: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug('Unable to parse output from kcadm get authentication/flows')
      return []
    end
    data.map { |f| f['alias'] }
  end

  def self.instances
    realms = []
    output = kcadm('get', 'realms')
    Puppet.debug("Realms: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug('Unable to parse output from kcadm get realms')
      data = []
    end
    data.each do |d|
      realm = {}
      realm[:ensure] = :present
      realm[:id] = d['id']
      realm[:name] = d['realm']
      events_config = get_events_config(d['realm'])
      type_properties.each do |property|
        next if [:default_client_scopes, :optional_client_scopes].include?(property)
        value = if property.to_s =~ %r{events}
                  events_config[camelize(property)]
                elsif browser_security_headers.include?(property)
                  d['browserSecurityHeaders'][camelize(property)]
                elsif smtp_server_properties.include?(property)
                  d['smtpServer'][camelize(property.to_s.gsub(%r{smtp_server_}, ''))]
                else
                  d[camelize(property)]
                end
        if !!value == value # rubocop:disable Style/DoubleNegation
          value = value.to_s.to_sym
        end
        realm[property.to_sym] = value
      end
      default_scopes = get_client_scopes(realm[:name], 'default')
      realm[:default_client_scopes] = default_scopes.keys.map { |k| k.to_s }
      optional_scopes = get_client_scopes(realm[:name], 'optional')
      realm[:optional_client_scopes] = optional_scopes.keys.map { |k| k.to_s }
      realms << new(realm)
    end
    realms
  end

  def self.prefetch(resources)
    realms = instances
    resources.keys.each do |name|
      provider = realms.find { |realm| realm.name == name }
      if provider
        resources[name].provider = provider
      end
    end
  end

  def create
    data = {}
    events_config = {}
    data[:id] = resource[:id]
    data[:realm] = resource[:name]
    type_properties.each do |property|
      next if flow_properties.include?(property)
      next if [:default_client_scopes, :optional_client_scopes].include?(property)
      if self.class.browser_security_headers.include?(property) && !data.key?('browserSecurityHeaders')
        data['browserSecurityHeaders'] = {}
      end
      if self.class.smtp_server_properties.include?(property) && !data.key?('smtpServer')
        data['smtpServer'] = {}
      end
      if property.to_s =~ %r{events}
        events_config[camelize(property)] = convert_property_value(resource[property.to_sym])
      elsif resource[property.to_sym]
        if self.class.browser_security_headers.include?(property)
          data['browserSecurityHeaders'][camelize(property)] = convert_property_value(resource[property.to_sym])
        elsif self.class.smtp_server_properties.include?(property) && resource[property]
          data['smtpServer'][camelize(property.to_s.gsub(%r{smtp_server_}, ''))] = resource[property]
        else
          data[camelize(property)] = convert_property_value(resource[property.to_sym])
        end
      end
    end

    t = Tempfile.new('keycloak_realm')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      [
        :login_theme,
        :account_theme,
        :admin_theme,
        :email_theme,
      ].each do |theme|
        if resource[theme]
          check_theme_exists(resource[theme], "Keycloak_realm[#{resource[:name]}]")
        end
      end
      kcadm('create', 'realms', nil, t.path)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm create realm failed\nError message: #{e.message}"
    end
    scope_id = nil
    if resource[:default_client_scopes]
      default_scopes = default_scopes ||= get_client_scopes(resource[:name], 'default')
      remove_default_scopes = default_scopes.keys - resource[:default_client_scopes]
      begin
        remove_default_scopes.each do |s|
          scope_id = default_scopes[s]
          kcadm('delete', "realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}")
        end
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm delete realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:optional_client_scopes]
      optional_scopes = optional_scopes ||= get_client_scopes(resource[:name], 'optional')
      remove_optional_scopes = optional_scopes.keys - resource[:optional_client_scopes]
      begin
        remove_optional_scopes.each do |s|
          scope_id = optional_scopes[s]
          kcadm('delete', "realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}")
        end
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm delete realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:default_client_scopes]
      default_scopes = default_scopes ||= get_client_scopes(resource[:name], 'default')
      add_default_scopes = resource[:default_client_scopes] - default_scopes.keys
      begin
        add_default_scopes.each do |s|
          scope_id = default_scopes[s]
          kcadm('update', "realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}")
        end
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    if resource[:optional_client_scopes]
      optional_scopes = optional_scopes ||= get_client_scopes(resource[:name], 'optional')
      add_optional_scopes = resource[:optional_client_scopes] - optional_scopes.keys
      begin
        add_optional_scopes.each do |s|
          scope_id = optional_scopes[s]
          kcadm('update', "realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}")
        end
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}: #{e.message}"
      end
    end
    unless events_config.empty?
      events_config_t = Tempfile.new('keycloak_events_config')
      events_config_t.write(JSON.pretty_generate(events_config))
      events_config_t.close
      Puppet.debug(IO.read(events_config_t.path))
      begin
        kcadm('update', 'events/config', resource[:name], events_config_t.path)
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update events config failed\nError message: #{e.message}"
      end
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    begin
      kcadm('delete', "realms/#{resource[:name]}")
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
      data = {}
      events_config = {}
      type_properties.each do |property|
        next if [:default_client_scopes, :optional_client_scopes].include?(property)
        if flow_properties.include?(property) && !available_flows(resource[:name]).include?(resource[property.to_sym])
          Puppet.warning("Keycloak_realm[#{resource[:name]}]: #{property} '#{resource[property.to_sym]}' does not exist, skipping")
          next
        end
        if self.class.browser_security_headers.include?(property) && !data.key?('browserSecurityHeaders')
          data['browserSecurityHeaders'] = {}
        end
        if self.class.smtp_server_properties.include?(property) && !data.key?('smtpServer')
          data['smtpServer'] = {}
        end
        if @property_flush[property.to_sym] || resource[property.to_sym]
          if self.class.browser_security_headers.include?(property)
            data['browserSecurityHeaders'][camelize(property)] = convert_property_value(resource[property.to_sym])
          elsif self.class.smtp_server_properties.include?(property) && resource[property]
            data['smtpServer'][camelize(property.to_s.gsub(%r{smtp_server_}, ''))] = resource[property]
          else
            data[camelize(property)] = convert_property_value(resource[property.to_sym])
          end
        end
        if property.to_s =~ %r{events}
          events_config[camelize(property)] = convert_property_value(resource[property.to_sym])
        end
      end

      unless data.empty?
        t = Tempfile.new('keycloak_realm')
        t.write(JSON.pretty_generate(data))
        t.close
        Puppet.debug(IO.read(t.path))
        begin
          [
            :login_theme,
            :account_theme,
            :admin_theme,
            :email_theme,
          ].each do |theme|
            if @property_flush[theme]
              check_theme_exists(@property_flush[theme], "Keycloak_realm[#{resource[:name]}]")
            end
          end
          kcadm('update', "realms/#{resource[:name]}", nil, t.path)
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update realm failed\nError message: #{e.message}"
        end
      end
      scope_id = nil
      if @property_flush[:default_client_scopes]
        default_scopes = default_scopes ||= get_client_scopes(resource[:name], 'default')
        remove_default_scopes = default_scopes.keys - @property_flush[:default_client_scopes]
        begin
          remove_default_scopes.each do |s|
            scope_id = default_scopes[s]
            kcadm('delete', "realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}")
          end
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm delete realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:optional_client_scopes]
        optional_scopes = optional_scopes ||= get_client_scopes(resource[:name], 'optional')
        remove_optional_scopes = optional_scopes.keys - @property_flush[:optional_client_scopes]
        begin
          remove_optional_scopes.each do |s|
            scope_id = optional_scopes[s]
            kcadm('delete', "realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}")
          end
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm delete realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:default_client_scopes]
        default_scopes = default_scopes ||= get_client_scopes(resource[:name], 'default')
        add_default_scopes = @property_flush[:default_client_scopes] - default_scopes.keys
        begin
          add_default_scopes.each do |s|
            scope_id = default_scopes[s]
            kcadm('update', "realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}")
          end
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update realms/#{resource[:name]}/default-default-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      if @property_flush[:optional_client_scopes]
        optional_scopes = optional_scopes ||= get_client_scopes(resource[:name], 'optional')
        add_optional_scopes = @property_flush[:optional_client_scopes] - optional_scopes.keys
        begin
          add_optional_scopes.each do |s|
            scope_id = optional_scopes[s]
            kcadm('update', "realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}")
          end
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update realms/#{resource[:name]}/default-optional-client-scopes/#{scope_id}: #{e.message}"
        end
      end
      unless events_config.empty?
        events_config_t = Tempfile.new('keycloak_events_config')
        events_config_t.write(JSON.pretty_generate(events_config))
        events_config_t.close
        Puppet.debug(IO.read(events_config_t.path))
        begin
          kcadm('update', 'events/config', resource[:name], events_config_t.path)
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update events config failed\nError message: #{e.message}"
        end
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
