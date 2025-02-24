# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_client_protocol_mapper).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def self.attribute_nameformat_map
    {
      uri: 'URI Reference',
      basic: 'Basic',
      unspecified: 'Unspecified'
    }
  end

  def self.get_attribute_nameformat(attribute)
    attribute_nameformat_map[attribute.to_sym]
  end

  def self.get_attribute_nameformat_reverse(attribute)
    attribute_nameformat_map.invert[attribute]
  end

  def self.instances
    protocol_mappers = []
    realms.each do |realm|
      clients_output = kcadm('get', 'clients', realm)
      clients_data = JSON.parse(clients_output)
      clients_data.each do |client|
        client_id = client['id']
        data = client['protocolMappers'] || []
        data.each do |d|
          protocol_mapper = {}
          protocol_mapper[:ensure] = :present
          protocol_mapper[:id] = d['id']
          protocol_mapper[:realm] = realm
          protocol_mapper[:client] = client_id
          protocol_mapper[:resource_name] = d['name']
          protocol_mapper[:protocol] = d['protocol']
          protocol_mapper[:name] = "#{protocol_mapper[:resource_name]} for #{protocol_mapper[:client]} on #{protocol_mapper[:realm]}"
          protocol_mapper[:type] = d['protocolMapper']
          if protocol_mapper[:type] == 'oidc-usermodel-property-mapper' || protocol_mapper[:type] == 'saml-user-property-mapper'
            protocol_mapper[:user_attribute] = d['config']['user.attribute']
          end
          if ['oidc-usermodel-client-role-mapper', 'oidc-usermodel-property-mapper',
              'oidc-group-membership-mapper'].include?(protocol_mapper[:type]) || (protocol_mapper[:protocol] == 'openid-connect' && protocol_mapper[:type] =~ %r{script-.+})
            protocol_mapper[:claim_name] = d['config']['claim.name']
            protocol_mapper[:json_type_label] = d['config']['jsonType.label']
          end
          if protocol_mapper[:type] == 'oidc-usermodel-client-role-mapper'
            protocol_mapper[:usermodel_client_role_mapping_client_id] = d['config']['usermodel.clientRoleMapping.clientId']
          end
          if protocol_mapper[:type] == 'oidc-group-membership-mapper'
            protocol_mapper[:full_path] = d['config']['full.path']
          end
          if ['saml-user-property-mapper'].include?(protocol_mapper[:type]) || protocol_mapper[:type] =~ %r{script-.+}
            protocol_mapper[:friendly_name] = d['config']['friendly.name']
          end
          if protocol_mapper[:protocol] == 'openid-connect'
            protocol_mapper[:id_token_claim] = d['config']['id.token.claim']
            protocol_mapper[:access_token_claim] = d['config']['access.token.claim']
          end
          unless ['oidc-audience-mapper'].include?(protocol_mapper[:type])
            protocol_mapper[:userinfo_token_claim] = d['config']['userinfo.token.claim']
          end
          if protocol_mapper[:type] == 'oidc-audience-mapper'
            protocol_mapper[:included_client_audience] = d['config']['included.client.audience']
          end
          if protocol_mapper[:protocol] == 'saml'
            protocol_mapper[:attribute_name] = d['config']['attribute.name']
            protocol_mapper[:attribute_nameformat] = get_attribute_nameformat_reverse(d['config']['attribute.nameformat'])
          end
          if ['saml-role-list-mapper'].include?(protocol_mapper[:type]) || protocol_mapper[:type] =~ %r{script-.+}
            protocol_mapper[:single] = d['config']['single'].to_s.to_sym
          end
          protocol_mapper[:multivalued] = d['config']['multivalued'].to_s.to_sym if d['config']['multivalued']
          protocol_mapper[:aggregate_attrs] = d['config']['aggregate.attrs'].to_s.to_sym if d['config']['aggregate.attrs']
          protocol_mappers << new(protocol_mapper)
        end
      end
    end
    protocol_mappers
  end

  def self.prefetch(resources)
    protocol_mappers = instances
    resources.each_key do |name|
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
    if (resource[:type] == 'oidc-usermodel-property-mapper' || resource[:type] == 'saml-user-property-mapper') && resource[:user_attribute]
      data[:config][:'user.attribute'] = resource[:user_attribute]
    end
    if ['oidc-usermodel-client-role-mapper', 'oidc-usermodel-property-mapper',
        'oidc-group-membership-mapper'].include?(resource[:type]) || (resource[:protocol] == 'openid-connect' && resource[:type] =~ %r{script-.+})
      data[:config][:'claim.name'] = resource[:claim_name] if resource[:claim_name]
      data[:config][:'jsonType.label'] = resource[:json_type_label] if resource[:json_type_label]
    end
    if resource[:type] == 'oidc-group-membership-mapper' && resource[:full_path]
      data[:config][:'full.path'] = resource[:full_path]
    end
    if resource[:type] == 'oidc-usermodel-client-role-mapper' && resource[:usermodel_client_role_mapping_client_id]
      data[:config][:'usermodel.clientRoleMapping.clientId'] = resource[:usermodel_client_role_mapping_client_id]
    end
    if (['saml-user-property-mapper'].include?(resource[:type]) || (resource[:protocol] == 'saml' && resource[:type] =~ %r{script-.+})) && resource[:friendly_name]
      data[:config][:'friendly.name'] = resource[:friendly_name]
    end
    if resource[:protocol] == 'openid-connect'
      data[:config][:'id.token.claim'] = resource[:id_token_claim] if resource[:id_token_claim]
      data[:config][:'access.token.claim'] = resource[:access_token_claim] if resource[:access_token_claim]
    end
    if !['oidc-audience-mapper'].include?(resource[:type]) && resource[:userinfo_token_claim]
      data[:config][:'userinfo.token.claim'] = resource[:userinfo_token_claim]
    end
    if resource[:type] == 'oidc-audience-mapper' && resource[:included_client_audience]
      data[:config][:'included.client.audience'] = resource[:included_client_audience]
    end
    if resource[:protocol] == 'saml'
      data[:config][:'attribute.name'] = resource[:attribute_name] if resource[:attribute_name]
      data[:config][:'attribute.nameformat'] = self.class.get_attribute_nameformat(resource[:attribute_nameformat]) if resource[:attribute_nameformat]
    end
    if (['saml-role-list-mapper'].include?(resource[:type]) || (resource[:protocol] == 'saml' && resource[:type] =~ %r{script-.+})) && resource[:single]
      data[:config][:single] = resource[:single].to_s
    end
    if resource[:multivalued]
      data[:config][:multivalued] = resource[:multivalued].to_s
    end
    if resource[:aggregate_attrs]
      data[:config][:'aggregate.attrs'] = resource[:aggregate_attrs].to_s
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
      if (resource[:type] == 'oidc-usermodel-property-mapper' || resource[:type] == 'saml-user-property-mapper') && resource[:user_attribute]
        config[:'user.attribute'] = resource[:user_attribute]
      end
      if ['oidc-usermodel-client-role-mapper', 'oidc-usermodel-property-mapper',
          'oidc-group-membership-mapper'].include?(resource[:type]) || (resource[:protocol] == 'openid-connect' && resource[:type] =~ %r{script-.+})
        config[:'claim.name'] = resource[:claim_name] if resource[:claim_name]
        config[:'jsonType.label'] = resource[:json_type_label] if resource[:json_type_label]
      end
      if resource[:type] == 'oidc-group-membership-mapper' && resource[:full_path]
        config[:'full.path'] = resource[:full_path]
      end
      if resource[:type] == 'oidc-usermodel-client-role-mapper' && resource[:usermodel_client_role_mapping_client_id]
        config[:'usermodel.clientRoleMapping.clientId'] = resource[:usermodel_client_role_mapping_client_id]
      end
      if (['saml-user-property-mapper'].include?(resource[:type]) || (resource[:protocol] == 'saml' && resource[:type] =~ %r{script-.+})) && resource[:friendly_name]
        config[:'friendly.name'] = resource[:friendly_name]
      end
      if resource[:protocol] == 'openid-connect'
        config[:'id.token.claim'] = resource[:id_token_claim] if resource[:id_token_claim]
        config[:'access.token.claim'] = resource[:access_token_claim] if resource[:access_token_claim]
      end
      if !['oidc-audience-mapper'].include?(resource[:type]) && resource[:userinfo_token_claim]
        config[:'userinfo.token.claim'] = resource[:userinfo_token_claim]
      end
      if resource[:type] == 'oidc-audience-mapper' && resource[:included_client_audience]
        config[:'included.client.audience'] = resource[:included_client_audience]
      end
      if resource[:protocol] == 'saml'
        config[:'attribute.name'] = resource[:attribute_name] if resource[:attribute_name]
        config[:'attribute.nameformat'] = self.class.get_attribute_nameformat(resource[:attribute_nameformat]) if resource[:attribute_nameformat]
      end
      if (['saml-role-list-mapper'].include?(resource[:type]) || (resource[:protocol] == 'saml' && resource[:type] =~ %r{script-.+})) && resource[:single]
        config[:single] = resource[:single].to_s
      end
      if resource[:multivalued]
        config[:multivalued] = resource[:multivalued].to_s
      end
      if resource[:aggregate_attrs]
        config[:'aggregate.attrs'] = resource[:aggregate_attrs].to_s
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
