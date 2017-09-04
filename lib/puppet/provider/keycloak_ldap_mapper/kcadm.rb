require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_ldap_mapper).provide(:kcadm, :parent => Puppet::Provider::Keycloak_API) do
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
        next unless d['providerType'] == 'org.keycloak.storage.ldap.mappers.LDAPStorageMapper'
        next unless d['providerId'] == 'user-attribute-ldap-mapper' || d['providerId'] == 'full-name-ldap-mapper'
        component = {}
        component[:ensure] = :present
        component[:id] = d['id']
        component[:realm] = realm
        component[:resource_name] = d['name']
        component[:ldap] = d['parentId']
        component[:type] = d['providerId']
        component[:name] = "#{component[:resource_name]} for #{component[:ldap]} on #{component[:realm]}"
        type_properties.each do |property|
          if property == :ldap_attribute and component[:type] == 'full-name-ldap-mapper'
            key = 'ldap.full.name.attribute'
          else
            key = property.to_s.gsub('_', '.')
          end
          next unless d['config'].key?(key)
          value = d['config'][key][0]
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
      if provider = components.find { |c|
        c.resource_name == resources[name][:resource_name] &&
        c.realm == resources[name][:realm]
      }
        resources[name].provider = provider
      end
    end
  end

  def create
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    fail("Ldap is mandatory for #{resource.type} #{resource.name}") if resource[:ldap].nil?

    data = {}
    data[:id] = resource[:id]
    data[:name] = resource[:resource_name]
    data[:parentId] = resource[:ldap]
    data[:providerId] = resource[:type]
    data[:providerType] = 'org.keycloak.storage.ldap.mappers.LDAPStorageMapper'
    data[:config] = {}
    type_properties.each do |property|
      if resource[property.to_sym]
        if property == :ldap_attribute and resource[:type] == 'full-name-ldap-mapper'
          key = 'ldap.full.name.attribute'
        else
          key = property.to_s.gsub('_', '.')
        end
        # is.mandatory.in.ldap and user.model.attribute only belong to user-attribute-ldap-mapper
        if resource[:type] != 'user-attribute-ldap-mapper'
          if property == :is_mandatory_in_ldap || property == :user_model_attribute
            next
          end
        end
        data[:config][key] = [resource[property.to_sym]]
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
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    begin
      kcadm('delete', "components/#{resource[:id]}", resource[:realm])
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
      fail("Ldap is mandatory for #{resource.type} #{resource.name}") if resource[:ldap].nil?

      data = {}
      data[:providerId] = resource[:type]
      data[:providerType] = 'org.keycloak.storage.ldap.mappers.LDAPStorageMapper'
      data[:config] = {}
      type_properties.each do |property|
        if @property_flush[property.to_sym]
          if property == :ldap_attribute and resource[:type] == 'full-name-ldap-mapper'
            key = 'ldap.full.name.attribute'
          else
            key = property.to_s.gsub('_', '.')
          end
          # is.mandatory.in.ldap and user.model.attribute only belong to user-attribute-ldap-mapper
          if resource[:type] != 'user-attribute-ldap-mapper'
            if property == :is_mandatory_in_ldap || property == :user_model_attribute
              next
            end
          end
          data[:config][key] = [resource[property.to_sym]]
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
