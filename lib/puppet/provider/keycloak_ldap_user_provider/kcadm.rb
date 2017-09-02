require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_ldap_user_provider).provide(:kcadm, :parent => Puppet::Provider::Keycloak_API) do
  desc ""

  mk_resource_methods

  def self.instances
    components = []

    realms = get_realms()

    realms.each do |realm|
      output = kcadm('get', 'components', realm)
      Puppet.debug("#{realm} components: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError => e
        Puppet.debug('Unable to parse output from kcadm get components')
        data = []
      end

      data.each do |d|
        next unless d['providerType'] == 'org.keycloak.storage.UserStorageProvider'
        next unless d['providerId'] == 'ldap'
        component = {}
        component[:ensure] = :present
        component[:id] = d['id']
        component[:resource_name] = d['name']
        component[:realm] = d['parentId']
        component[:name] = "#{component[:resource_name]} on #{component[:realm]}"
        type_properties.each do |property|
          next unless d['config'].key?(camelize(property).gsub(/ldap/i, 'LDAP'))
          value = d['config'][camelize(property).gsub(/ldap/i, 'LDAP')][0]
          if !!value == value
            value = value.to_s.to_sym
          end
          component[property.to_sym] = value
        end
        components << new(component)
      end
    end
    components
  end

  def self.prefetch(resources)
    components = instances
    resources.keys.each do |name|
      if provider = components.find { |c| c.resource_name == resources[name][:resource_name] && c.realm == resources[name][:realm] }
        resources[name].provider = provider
      end
    end
  end

  def create
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    data = {}
    data[:id] = resource[:id]
    data[:name] = resource[:resource_name]
    data[:parentId] = resource[:realm]
    data[:providerId] = 'ldap'
    data[:providerType] = 'org.keycloak.storage.UserStorageProvider'
    data[:config] = {}
    type_properties.each do |property|
      if resource[property.to_sym]
        data[:config][camelize(property).gsub(/ldap/i, 'LDAP')] = [resource[property.to_sym]]
      end
    end

    t = Tempfile.new('keycloak_component')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', 'components', resource[:realm], t.path)
    rescue Exception => e
      raise Puppet::Error, "kcadm create component failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    begin
      kcadm('delete', "components/#{resource[:id]}")
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
      data[:providerId] = 'ldap'
      data[:providerType] = 'org.keycloak.storage.UserStorageProvider'
      data[:config] = {}
      type_properties.each do |property|
        if @property_flush[property.to_sym] # || resource[property.to_sym]
          data[:config][camelize(property).gsub(/ldap/i, 'LDAP')] = [resource[property.to_sym]]
        end
      end

      t = Tempfile.new('keycloak_component')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "components/#{resource[:id]}", resource[:realm], t.path)
      rescue Exception => e
        raise Puppet::Error, "kcadm update component failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end

end
