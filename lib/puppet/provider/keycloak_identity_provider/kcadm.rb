# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_identity_provider).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def top_level_properties
    [
      :enabled, :display_name, :update_profile_first_login_mode, :trust_email, :store_token, :add_read_token_role_on_create,
      :authenticate_by_default, :link_only, :first_broker_login_flow_alias, :post_broker_login_flow_alias,
    ]
  end

  def self.instances
    providers = []
    realms.each do |realm|
      output = kcadm('get', 'identity-provider/instances', realm)
      Puppet.debug("#{realm} identity-provider/instances: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get identity-provider/instances')
        data = []
      end

      data.each do |d|
        provider = {}
        provider[:ensure] = :present
        provider[:internal_id] = d['internalId']
        provider[:alias] = d['alias']
        provider[:realm] = realm
        provider[:name] = "#{provider[:alias]} on #{provider[:realm]}"
        provider[:provider_id] = d['providerId']
        type_properties.each do |property|
          key = camelize(property)
          if d.key?(key)
            value = d[key]
          elsif d['config'].key?(key)
            value = d['config'][key]
          else
            next
          end
          if ['true', 'false'].include?(value)
            value = value.to_sym
          elsif !!value == value # rubocop:disable Style/DoubleNegation
            value = value.to_s.to_sym
          end
          provider[property.to_sym] = value
        end
        providers << new(provider)
      end
    end
    providers
  end

  def self.prefetch(resources)
    providers = instances
    resources.each_key do |name|
      provider = providers.find { |c| c.alias == resources[name][:alias] && c.realm == resources[name][:realm] }
      if provider
        resources[name].provider = provider
      end
    end
  end

  def create
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    data = {}
    data[:alias] = resource[:alias]
    data[:internalId] = resource[:internal_id]
    data[:providerId] = resource[:provider_id]
    data[:config] = {}
    type_properties.each do |property|
      next unless resource[property.to_sym]

      value = resource[property.to_sym]
      next if value == :absent

      key = camelize(property)
      if top_level_properties.include?(property)
        data[key] = value
      else
        if [:true, :false].include?(value.to_sym)
          value = value.to_s
        end
        data[:config][key] = value
      end
    end

    t = Tempfile.new('keycloak_identity_provider')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', 'identity-provider/instances', resource[:realm], t.path)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm create identify provider failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    begin
      kcadm('delete', "identity-provider/instances/#{resource[:alias]}", resource[:realm])
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
      data[:alias] = resource[:alias]
      data[:internalId] = resource[:internal_id]
      data[:providerId] = resource[:provider_id]
      data[:config] = {}
      type_properties.each do |property|
        value = @property_flush[property.to_sym] || resource[property.to_sym]
        value = '' if value == :absent
        key = camelize(property)
        if top_level_properties.include?(property)
          data[key] = value
        else
          if !value.nil? && [:true, :false].include?(value.to_sym)
            value = value.to_s
          end
          data[:config][key] = value
        end
      end

      t = Tempfile.new('keycloak_identity_provider')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "identity-provider/instances/#{resource[:alias]}", resource[:realm], t.path)
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update identity-provider failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
