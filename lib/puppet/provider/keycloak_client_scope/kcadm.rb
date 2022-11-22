# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_client_scope).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def self.instances
    client_scopes = []
    realms.each do |realm|
      output = kcadm('get', 'client-scopes', realm)
      Puppet.debug("#{realm} client-scopes: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get client-scopes')
        data = []
      end

      data.each do |d|
        client_scope = {}
        client_scope[:ensure] = :present
        client_scope[:id] = d['id']
        client_scope[:realm] = realm
        client_scope[:resource_name] = d['name']
        client_scope[:name] = "#{client_scope[:resource_name]} on #{client_scope[:realm]}"
        client_scope[:protocol] = d['protocol']
        attributes = d['attributes'] || {}
        client_scope[:consent_screen_text] = attributes['consent.screen.text']
        client_scope[:display_on_consent_screen] = attributes['display.on.consent.screen']
        client_scopes << new(client_scope)
      end
    end
    client_scopes
  end

  def self.prefetch(resources)
    client_scopes = instances
    resources.each_key do |name|
      provider = client_scopes.find { |c| c.resource_name == resources[name][:resource_name] && c.realm == resources[name][:realm] }
      if provider
        resources[name].provider = provider
      end
    end
  end

  def create
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    data = {}
    data[:id] = resource[:id]
    data[:name] = resource[:resource_name]
    data[:protocol] = resource[:protocol]
    attributes = {}
    attributes['consent.screen.text'] = resource[:consent_screen_text]
    attributes['display.on.consent.screen'] = resource[:display_on_consent_screen]
    data[:attributes] = attributes

    t = Tempfile.new('keycloak_client_scope')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', 'client-scopes', resource[:realm], t.path)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm create client-scope failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    begin
      kcadm('delete', "client-scopes/#{id}", resource[:realm])
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
      data[:name] = resource[:resource_name]
      data[:protocol] = @property_flush[:protocol] if @property_flush[:protocol]
      attributes = {}
      attributes['consent.screen.text'] = @property_flush[:consent_screen_text] if @property_flush[:consent_screen_text]
      attributes['display.on.consent.screen'] = @property_flush[:display_on_consent_screen] if @property_flush[:display_on_consent_screen]
      data[:attributes] = attributes if attributes

      t = Tempfile.new('keycloak_client_scope')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "client-scopes/#{id}", resource[:realm], t.path)
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update client-scope failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
