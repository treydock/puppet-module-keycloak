# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_ldap_mapper).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def type_supported_properties(type)
    supported = {
      'user-attribute-ldap-mapper' => [
        :is_mandatory_in_ldap, :user_model_attribute, :always_read_value_from_ldap, :ldap_attribute, :read_only
      ],
      'full-name-ldap-mapper' => [
        :write_only, :ldap_attribute, :read_only
      ],
      'group-ldap-mapper' => [
        :mode, :membership_attribute_type, :user_roles_retrieve_strategy,
        :group_name_ldap_attribute, :ignore_missing_groups, :membership_user_ldap_attribute,
        :membership_ldap_attribute, :preserve_group_inheritance, :groups_dn,
        :mapped_group_attributes, :groups_ldap_filter, :memberof_ldap_attribute,
        :group_object_classes, :drop_non_existing_groups_during_sync
      ],
      'role-ldap-mapper' => [
        :mode, :membership_attribute_type, :user_roles_retrieve_strategy, :membership_user_ldap_attribute,
        :membership_ldap_attribute, :memberof_ldap_attribute, :roles_dn, :role_name_ldap_attribute,
        :role_object_classes, :roles_ldap_filter, :use_realm_roles_mapping, :client_id
      ]
    }
    supported[type]
  end

  def self.instances
    components = []
    realms.each do |realm|
      component_ids = {}
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

        component_ids[d['id']] = d['name']
      end
      Puppet.debug("Realm #{realm} component_ids: #{component_ids}")

      data.each do |d|
        next unless d['providerType'] == 'org.keycloak.storage.ldap.mappers.LDAPStorageMapper'
        next unless [
          'user-attribute-ldap-mapper', 'full-name-ldap-mapper', 'group-ldap-mapper', 'role-ldap-mapper'
        ].include?(d['providerId'])

        component = {}
        component[:ensure] = :present
        component[:id] = d['id']
        component[:realm] = realm
        component[:resource_name] = d['name']
        component[:parent_id] = d['parentId']
        component[:ldap] = component_ids[component[:parent_id]]
        component[:type] = d['providerId']
        component[:name] = "#{component[:resource_name]} for #{component[:ldap]} on #{component[:realm]}"
        type_properties.each do |property|
          key = if property == :ldap_attribute && component[:type] == 'full-name-ldap-mapper'
                  'ldap.full.name.attribute'
                else
                  property.to_s.tr('_', '.')
                end
          unless d['config'].key?(key)
            component[property.to_sym] = :absent
            next
          end

          value = d['config'][key][0]
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
      provider = components.find do |c|
        c.resource_name == resources[name][:resource_name] &&
          c.realm == resources[name][:realm] &&
          c.ldap == resources[name][:ldap]
      end
      next unless provider

      resources[name].provider = provider
    end
  end

  def get_parent_id(ldap, realm)
    parent_id = nil
    output = kcadm('get', 'components', realm, nil, ['name', 'realm', 'id', 'providerType'])
    Puppet.debug("#{realm} components: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError
      Puppet.debug('Unable to parse output from kcadm get components')
      data = []
    end
    data.each do |d|
      next unless d['providerType'] == 'org.keycloak.storage.UserStorageProvider'

      if d['name'] == ldap
        parent_id = d['id']
      end
    end
    parent_id
  end

  def create
    data = {}
    data[:id] = resource[:id] || name_uuid(resource[:name])
    data[:name] = resource[:resource_name]
    data[:parentId] = resource[:parent_id] || get_parent_id(resource[:ldap], resource[:realm]) || name_uuid(resource[:ldap])
    data[:providerId] = resource[:type]
    data[:providerType] = 'org.keycloak.storage.ldap.mappers.LDAPStorageMapper'
    data[:config] = {}
    type_properties.each do |property|
      next unless resource[property.to_sym]
      next if resource[property.to_sym].to_s == 'absent'

      key = if property == :ldap_attribute && resource[:type] == 'full-name-ldap-mapper'
              'ldap.full.name.attribute'
            else
              property.to_s.tr('_', '.')
            end
      next unless type_supported_properties(resource[:type]).include?(property.to_sym)

      data[:config][key] = [resource[property.to_sym]]
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
      data = {}
      data[:providerId] = resource[:type]
      data[:providerType] = 'org.keycloak.storage.ldap.mappers.LDAPStorageMapper'
      data[:config] = {}
      type_properties.each do |property|
        next unless @property_flush[property.to_sym]

        key = if property == :ldap_attribute && resource[:type] == 'full-name-ldap-mapper'
                'ldap.full.name.attribute'
              else
                property.to_s.tr('_', '.')
              end
        next unless type_supported_properties(resource[:type]).include?(property.to_sym)

        value = [resource[property.to_sym]]
        if @property_flush[property.to_sym].to_s == 'absent'
          value = ['']
        end
        data[:config][key] = value
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
