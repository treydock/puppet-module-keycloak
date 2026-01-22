# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_required_action).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def self.prefetch(resources)
    action_providers = instances
    resources.each_key do |name|
      provider = action_providers.find do |c|
        c.provider_id == resources[name][:provider_id] && c.realm == resources[name][:realm]
      end
      if provider
        resources[name].provider = provider
      end
    end
  end

  def self.instances
    action_instances = []
    realms.each do |realm|
      output = kcadm('get', 'authentication/required-actions', realm)
      Puppet.debug("#{realm} required-actions: #{output}")
      begin
        required_actions = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get required-actions')
        required_actions = []
      end

      required_actions.each do |a|
        action = {
          ensure: :present,
          display_name: a['name'],
          realm: realm,
          enabled: a['enabled'],
          provider_id: a['providerId'],
          name: "#{a['providerId']} on #{realm}",
          priority: a['priority'],
          config: a['config'],
          default: a['defaultAction']
        }

        Puppet.debug("Keycloak REQUIRED ACTION: #{action}")
        action_instances << new(action)
      end

      output = kcadm('get', 'authentication/unregistered-required-actions', realm)
      Puppet.debug("#{realm} unregistered-required-actions: #{output}")
      begin
        unregistered_actions = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get unregistered-required-actions')
        unregistered_actions = []
      end

      unregistered_actions.each do |a|
        action = {
          ensure: :absent,
          display_name: a['name'],
          realm: realm,
          enabled: false,
          default: false,
          provider_id: a['providerId'],
          name: "#{a['providerId']} on #{realm}"
        }

        Puppet.debug("Keycloak UNREGISTERED REQUIRED ACTION: #{action}")
        action_instances << new(action)
      end
    end
    action_instances
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

  def create
    Puppet.debug('Keycloak required action: create')

    t = Tempfile.new('keycloak_required_action_register')
    t.write(JSON.pretty_generate(providerId: resource[:provider_id], name: resource[:display_name]))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', 'authentication/register-required-action', resource[:realm], t.path)
    rescue StandardError => e
      raise Puppet::Error, "kcadm registration of required action failed\nError message: #{e.message}"
    end
    Puppet.info("Keycloak: registered required action for provider #{resource[:provider_id]} for #{resource[:realm]}")

    # Asigning property_flush to is needed to make the flush method to
    # configure properties of the required action after the registration.
    @property_flush = resource.to_hash
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug('Keycloak required action: destroy')
    begin
      kcadm('delete', "authentication/required-actions/#{@property_hash[:provider_id]}", resource[:realm])
    rescue StandardError => e
      raise Puppet::Error, "kcadm deletion of required action failed\nError message: #{e.message}"
    end
    Puppet.info("Keycloak: deregistered required action #{@property_hash[:provider_id]} for #{resource[:realm]}")
    @property_hash.clear
  end

  def exists?
    !(@property_hash[:ensure] == :absent || @property_hash.empty?)
  end

  def flush
    Puppet.debug("Keycloak property_flush: #{@property_flush}")
    return if @property_flush.empty?

    begin
      t = Tempfile.new('keycloak_required_action_configure')
      t.write(JSON.pretty_generate(alias: resource[:provider_id],
                                   name: resource[:display_name] || @property_hash[:display_name],
                                   enabled: resource[:enabled],
                                   priority: resource[:priority],
                                   config: resource[:config] || {},
                                   defaultAction: resource[:default]))
      t.close
      Puppet.debug(IO.read(t.path))
      kcadm('update', "authentication/required-actions/#{@property_hash[:provider_id]}", resource[:realm], t.path)
      Puppet.info("Keycloak: configured required action #{@property_hash[:display_name]} (provider #{resource[:provider_id]}) for #{resource[:realm]}")
    rescue StandardError => e
      raise Puppet::Error, "kcadm configuration of required action failed\nError message: #{e.message}"
    end

    @property_flush.clear
    @property_hash = resource.to_hash
  end

  def to_keycloak_representation(resource)
    {
      name: resource[:display_name],
      realm: resource[:realm],
      providerId: resource[:provider_id],
      enabled: resource[:ensure] == :present,
      priority: resource[:priority],
      config: resource[:config],
      defaultAction: resource[:default]
    }
  end
end
