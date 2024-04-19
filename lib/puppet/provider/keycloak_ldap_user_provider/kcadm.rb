# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_ldap_user_provider).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def self.instances
    components = []
    realms.each do |realm|
      output = kcadm('get', 'components', realm)
      Puppet.debug("#{realm} components: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError
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
          next unless d['config'].key?(camelize(property).gsub(%r{ldap}i, 'LDAP'))

          value = d['config'][camelize(property).gsub(%r{ldap}i, 'LDAP')][0]
          if property == :user_object_classes
            value = value.split(',')
          end
          if !!value == value # rubocop:disable Style/DoubleNegation
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
    resources.each_key do |name|
      provider = components.find { |c| c.id == resources[name][:id] }
      if provider
        resources[name].provider = provider
      end
    end
  end

  def get_parent_id(realm)
    parent_id = nil
    output = kcadm('get', 'realms', realm, nil, ['id'])
    Puppet.debug("#{realm} realms: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug('Unable to parse output from kcadm get realms')
      data = []
    end
    data.each do |d|
      parent_id = d['id']
    end
    parent_id
  end

  def create
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    data = {}
    data[:id] = resource[:id] || name_uuid(resource[:name])
    data[:name] = resource[:resource_name]
    data[:parentId] = get_parent_id(resource[:realm]) || resource[:realm]
    data[:providerId] = 'ldap'
    data[:providerType] = 'org.keycloak.storage.UserStorageProvider'
    data[:config] = {}
    type_properties.each do |property|
      next unless resource[property.to_sym]

      value = if property == :user_object_classes
                resource[property.to_sym].join(',')
              else
                resource[property.to_sym]
              end
      next if value == :absent

      data[:config][camelize(property).gsub(%r{ldap}i, 'LDAP')] = [value]
    end

    t = Tempfile.new('keycloak_component')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', 'components', resource[:realm], t.path)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm create component failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    begin
      kcadm('delete', "components/#{id}", resource[:realm])
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
      data[:providerId] = 'ldap'
      data[:providerType] = 'org.keycloak.storage.UserStorageProvider'
      data[:config] = {}
      type_properties.each do |property|
        next unless @property_flush[property.to_sym]

        value = if property == :user_object_classes
                  resource[property.to_sym].join(',')
                else
                  resource[property.to_sym]
                end
        if value == :absent
          value = ''
        end
        data[:config][camelize(property).gsub(%r{ldap}i, 'LDAP')] = [value]
      end

      t = Tempfile.new('keycloak_component')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "components/#{id}", resource[:realm], t.path)
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update component failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
