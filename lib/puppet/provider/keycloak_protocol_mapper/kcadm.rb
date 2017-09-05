require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_protocol_mapper).provide(:kcadm, :parent => Puppet::Provider::Keycloak_API) do
  desc ""

  mk_resource_methods

  def self.instances
    protocol_mappers = []

    realms = get_realms()

    realms.each do |realm|
      client_templates_output = kcadm('get', 'client-templates', realm, nil, ['id'])
      client_template_data = JSON.parse(client_templates_output)
      client_templates = client_template_data.map { |c| c['id'] }
      client_templates.each do |client_template|
        output = kcadm('get', "client-templates/#{client_template}/protocol-mappers/models", realm)
        Puppet.debug("#{realm} #{client_template} protocl-mappers: #{output}")
        begin
          data = JSON.parse(output)
        rescue JSON::ParserError => e
          Puppet.debug("Unable to parse output from kcadm get protocl-mappers")
          data = []
        end
        data.each do |d|
          protocol_mapper = {}
          protocol_mapper[:ensure] = :present
          protocol_mapper[:id] = d['id']
          protocol_mapper[:realm] = realm
          protocol_mapper[:client_template] = client_template
          protocol_mapper[:resource_name] = d['name']
          protocol_mapper[:protocol] = d['protocol']
          protocol_mapper[:name] = "#{protocol_mapper[:resource_name]} for #{protocol_mapper[:client_template]} on #{protocol_mapper[:realm]}"
          protocol_mapper[:type] = d['protocolMapper']
          protocol_mapper[:consent_required] = d['consentRequired'].to_s.to_sym
          protocol_mapper[:consent_text] = d['consentText']
          if protocol_mapper[:type] == 'oidc-usermodel-property-mapper'
            protocol_mapper[:user_attribute] = d['config']['user.attribute']
            protocol_mapper[:claim_name] = d['config']['claim.name']
            protocol_mapper[:json_type_label] = d['config']['jsonType.label']
          end
          protocol_mapper[:id_token_claim] = d['config']['id.token.claim']
          protocol_mapper[:access_token_claim] = d['config']['access.token.claim']
          protocol_mapper[:userinfo_token_claim] = d['config']['userinfo.token.claim']
          protocol_mappers << new(protocol_mapper)
        end
      end
    end
    protocol_mappers
  end

  def self.prefetch(resources)
    protocol_mappers = instances
    resources.keys.each do |name|
      if provider = protocol_mappers.find { |c|
        c.resource_name == resources[name][:resource_name] &&
        c.realm == resources[name][:realm] &&
        c.client_template = resources[name][:client_template]
      }
        resources[name].provider = provider
      end
    end
  end

  def create
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    fail("Client template is mandatory for #{resource.type} #{resource.name}") if resource[:client_template].nil?

    data = {}
    data[:id] = resource[:id]
    data[:name] = resource[:resource_name]
    data[:protocol] = resource[:protocol]
    data[:protocolMapper] = resource[:type]
    data[:consentRequired] = resource[:consent_required] if resource[:consent_required]
    data[:consentText] = resource[:consent_text] if resource[:consent_text]
    data[:config] = {}
    if resource[:type] == 'oidc-usermodel-property-mapper'
      data[:config][:'user.attribute'] = resource[:user_attribute] if resource[:user_attribute]
      data[:config][:'claim.name'] = resource[:claim_name] if resource[:claim_name]
      data[:config][:'jsonType.label'] = resource[:json_type_label] if resource[:json_type_label]
    end
    data[:config][:'id.token.claim'] = resource[:id_token_claim] if resource[:id_token_claim]
    data[:config][:'access.token.claim'] = resource[:access_token_claim] if resource[:access_token_claim]
    data[:config][:'userinfo.token.claim'] = resource[:userinfo_token_claim] if resource[:userinfo_token_claim]

    t = Tempfile.new('keycloak_protocol_mapper')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', "client-templates/#{resource[:client_template]}/protocol-mappers/models", resource[:realm], t.path)
    rescue Exception => e
      raise Puppet::Error, "kcadm create protocol-mapper failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    fail("Client template is mandatory for #{resource.type} #{resource.name}") if resource[:client_template].nil?
    id = @property_hash[:id] || resource[:id]
    begin
      kcadm('delete', "client-templates/#{resource[:client_template]}/protocol-mappers/models/#{id}", resource[:realm])
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
      fail("Client template is mandatory for #{resource.type} #{resource.name}") if resource[:client_template].nil?

      data = {}
      data[:id] = @property_hash[:id]
      data[:name] = resource[:resource_name]
      data[:protocol] = resource[:protocol]
      data[:protocolMapper] = resource[:type]
      data[:consentRequired] = resource[:consent_required] if resource[:consent_required]
      data[:consentText] = resource[:consent_text] if resource[:consent_text]
      config = {}
      if resource[:type] == 'oidc-usermodel-property-mapper'
        config[:'user.attribute'] = resource[:user_attribute] if resource[:user_attribute]
        config[:'claim.name'] = resource[:claim_name] if resource[:claim_name]
        config[:'jsonType.label'] = resource[:json_type_label] if resource[:json_type_label]
      end
      config[:'id.token.claim'] = resource[:id_token_claim] if resource[:id_token_claim]
      config[:'access.token.claim'] = resource[:access_token_claim] if resource[:access_token_claim]
      config[:'userinfo.token.claim'] = resource[:userinfo_token_claim] if resource[:userinfo_token_claim]
      data[:config] = config unless config.empty?

      t = Tempfile.new('keycloak_protocol_mapper')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "client-templates/#{resource[:client_template]}/protocol-mappers/models/#{@property_hash[:id]}", resource[:realm], t.path)
      rescue Exception => e
        raise Puppet::Error, "kcadm update component failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end

end
