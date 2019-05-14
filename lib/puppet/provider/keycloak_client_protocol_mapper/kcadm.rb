require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_client_protocol_mapper).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def self.attribute_nameformat_map
    {
      uri: 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri',
      basic: 'Basic',
      unspecified: 'Unspecified',
    }
  end

  def self.get_attribute_nameformat(v)
    attribute_nameformat_map[v.to_sym]
  end

  def self.get_attribute_nameformat_reverse(v)
    attribute_nameformat_map.invert[v]
  end

  def self.instances
    protocol_mappers = []
    realms.each do |realm|
      clients_output = kcadm('get', 'clients', realm, nil, ['id'])
      clients_data = JSON.parse(clients_output)
      clients = clients_data.map { |c| c['id'] }
      clients.each do |client|
        output = kcadm('get', "clients/#{client}/protocol-mappers/models", realm)
        Puppet.debug("#{realm} #{client} protocl-mappers: #{output}")
        begin
          data = JSON.parse(output)
        rescue JSON::ParserError
          Puppet.debug('Unable to parse output from kcadm get protocl-mappers')
          data = []
        end
        data.each do |d|
          protocol_mapper = {}
          protocol_mapper[:ensure] = :present
          protocol_mapper[:id] = d['id']
          protocol_mapper[:realm] = realm
          protocol_mapper[:client] = client
          protocol_mapper[:resource_name] = d['name']
          protocol_mapper[:protocol] = d['protocol']
          protocol_mapper[:name] = "#{protocol_mapper[:resource_name]} for #{protocol_mapper[:client]} on #{protocol_mapper[:realm]}"
          protocol_mapper[:type] = d['protocolMapper']
          if protocol_mapper[:type] == 'oidc-usermodel-property-mapper' || protocol_mapper[:type] == 'saml-user-property-mapper'
            protocol_mapper[:user_attribute] = d['config']['user.attribute']
          end
          if protocol_mapper[:type] == 'oidc-usermodel-property-mapper'
            protocol_mapper[:claim_name] = d['config']['claim.name']
            protocol_mapper[:json_type_label] = d['config']['jsonType.label']
          end
          if protocol_mapper[:type] == 'saml-user-property-mapper'
            protocol_mapper[:friendly_name] = d['config']['friendly.name']
          end
          if protocol_mapper[:protocol] == 'openid-connect'
            protocol_mapper[:id_token_claim] = d['config']['id.token.claim']
            protocol_mapper[:access_token_claim] = d['config']['access.token.claim']
            protocol_mapper[:userinfo_token_claim] = d['config']['userinfo.token.claim']
          end
          if protocol_mapper[:protocol] == 'saml'
            protocol_mapper[:attribute_name] = d['config']['attribute.name']
            protocol_mapper[:attribute_nameformat] = get_attribute_nameformat_reverse(d['config']['attribute.nameformat'])
          end
          if protocol_mapper[:type] == 'saml-role-list-mapper'
            protocol_mapper[:single] = d['config']['single'].to_s.to_sym
          end
          protocol_mappers << new(protocol_mapper)
        end
      end
    end
    protocol_mappers
  end

  def self.prefetch(resources)
    protocol_mappers = instances
    resources.keys.each do |name|
      provider = protocol_mappers.find do |c|
        c.resource_name == resources[name][:resource_name] &&
          c.realm == resources[name][:realm] &&
          c.client == resources[name][:client]
      end
      next unless provider
      resources[name].provider = provider
    end
  end

  def create
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    raise(Puppet::Error, "Client is mandatory for #{resource.type} #{resource.name}") if resource[:client].nil?

    data = {}
    data[:id] = resource[:id] || name_uuid(resource[:name])
    data[:name] = resource[:resource_name]
    data[:protocol] = resource[:protocol]
    data[:protocolMapper] = resource[:type]
    data[:config] = {}
    if resource[:type] == 'oidc-usermodel-property-mapper' || resource[:type] == 'saml-user-property-mapper'
      data[:config][:'user.attribute'] = resource[:user_attribute] if resource[:user_attribute]
    end
    if resource[:type] == 'oidc-usermodel-property-mapper'
      data[:config][:'claim.name'] = resource[:claim_name] if resource[:claim_name]
      data[:config][:'jsonType.label'] = resource[:json_type_label] if resource[:json_type_label]
    end
    if resource[:type] == 'saml-user-property-mapper'
      data[:config][:'friendly.name'] = resource[:friendly_name] if resource[:friendly_name]
    end
    if resource[:protocol] == 'openid-connect'
      data[:config][:'id.token.claim'] = resource[:id_token_claim] if resource[:id_token_claim]
      data[:config][:'access.token.claim'] = resource[:access_token_claim] if resource[:access_token_claim]
      data[:config][:'userinfo.token.claim'] = resource[:userinfo_token_claim] if resource[:userinfo_token_claim]
    end
    if resource[:protocol] == 'saml'
      data[:config][:'attribute.name'] = resource[:attribute_name] if resource[:attribute_name]
      data[:config][:'attribute.nameformat'] = self.class.get_attribute_nameformat(resource[:attribute_nameformat]) if resource[:attribute_nameformat]
    end
    if resource[:type] == 'saml-role-list-mapper'
      data[:config][:single] = resource[:single].to_s if resource[:single]
    end

    t = Tempfile.new('keycloak_protocol_mapper')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', "clients/#{resource[:client]}/protocol-mappers/models", resource[:realm], t.path)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm create protocol-mapper failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    raise(Puppet::Error, "Client is mandatory for #{resource.type} #{resource.name}") if resource[:client].nil?
    begin
      kcadm('delete', "clients/#{resource[:client]}/protocol-mappers/models/#{id}", resource[:realm])
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
      raise(Puppet::Error, "Client is mandatory for #{resource.type} #{resource.name}") if resource[:client].nil?

      data = {}
      data[:id] = id
      data[:name] = resource[:resource_name]
      data[:protocol] = resource[:protocol]
      data[:protocolMapper] = resource[:type]
      config = {}
      if resource[:type] == 'oidc-usermodel-property-mapper' || resource[:type] == 'saml-user-property-mapper'
        config[:'user.attribute'] = resource[:user_attribute] if resource[:user_attribute]
      end
      if resource[:type] == 'oidc-usermodel-property-mapper'
        config[:'claim.name'] = resource[:claim_name] if resource[:claim_name]
        config[:'jsonType.label'] = resource[:json_type_label] if resource[:json_type_label]
      end
      if resource[:type] == 'saml-user-property-mapper'
        config[:'friendly.name'] = resource[:friendly_name] if resource[:friendly_name]
      end
      if resource[:protocol] == 'openid-connect'
        config[:'id.token.claim'] = resource[:id_token_claim] if resource[:id_token_claim]
        config[:'access.token.claim'] = resource[:access_token_claim] if resource[:access_token_claim]
        config[:'userinfo.token.claim'] = resource[:userinfo_token_claim] if resource[:userinfo_token_claim]
      end
      if resource[:protocol] == 'saml'
        config[:'attribute.name'] = resource[:attribute_name] if resource[:attribute_name]
        config[:'attribute.nameformat'] = self.class.get_attribute_nameformat(resource[:attribute_nameformat]) if resource[:attribute_nameformat]
      end
      if resource[:type] == 'saml-role-list-mapper'
        config[:single] = resource[:single].to_s if resource[:single]
      end
      data[:config] = config unless config.empty?

      t = Tempfile.new('keycloak_protocol_mapper')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "clients/#{resource[:client]}/protocol-mappers/models/#{id}", resource[:realm], t.path)
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update component failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
