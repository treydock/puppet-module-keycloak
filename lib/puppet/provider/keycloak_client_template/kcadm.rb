require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_client_template).provide(:kcadm, :parent => Puppet::Provider::Keycloak_API) do
  desc ""

  mk_resource_methods

  def self.instances
    client_templates = []

    realms = get_realms()

    realms.each do |realm|
      output = kcadm('get', 'client-templates', realm)
      Puppet.debug("#{realm} client-templates: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError => e
        Puppet.debug('Unable to parse output from kcadm get client-templates')
        data = []
      end

      data.each do |d|
        client_template = {}
        client_template[:ensure] = :present
        client_template[:id] = d['id']
        client_template[:realm] = realm
        client_template[:resource_name] = d['name']
        client_template[:name] = "#{client_template[:resource_name]} on #{client_template[:realm]}"
        type_properties.each do |property|
          next unless d.key?(camelize(property))
          value = d[camelize(property)]
          if !!value == value
            value = value.to_s.to_sym
          end
          client_template[property.to_sym] = value
        end
        client_templates << new(client_template)
      end
    end
    client_templates
  end

  def self.prefetch(resources)
    client_templates = instances
    resources.keys.each do |name|
      if provider = client_templates.find { |c| c.resource_name == resources[name][:resource_name] && c.realm == resources[name][:realm] }
        resources[name].provider = provider
      end
    end
  end

  def create
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    data = {}
    data[:id] = resource[:id]
    data[:name] = resource[:resource_name]
    type_properties.each do |property|
      if resource[property.to_sym]
        data[camelize(property)] = resource[property.to_sym]
      end
    end

    t = Tempfile.new('keycloak_client_template')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', 'client-templates', resource[:realm], t.path)
    rescue Exception => e
      raise Puppet::Error, "kcadm create client-template failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    begin
      kcadm('delete', "client-templates/#{resource[:id]}", resource[:realm])
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
      data[:name] = resource[:resource_name]
      type_properties.each do |property|
        if @property_flush[property.to_sym]
          data[camelize(property)] = resource[property.to_sym]
        end
      end

      t = Tempfile.new('keycloak_client_template')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "client-templates/#{resource[:id]}", resource[:realm], t.path)
      rescue Exception => e
        raise Puppet::Error, "kcadm update client-template failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end

end
