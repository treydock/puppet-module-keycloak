require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_client).provide(:kcadm, :parent => Puppet::Provider::Keycloak_API) do
  desc ""

  mk_resource_methods

  def self.instances
    clients = []

    realms = get_realms()

    realms.each do |realm|
      output = kcadm('get', 'clients', realm)
      Puppet.debug("#{realm} clients: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError => e
        Puppet.debug('Unable to parse output from kcadm get clients')
        data = []
      end

      data.each do |d|
        # avoid built-in clients
        if d.key?('clientAuthenticatorType') &&
           d['clientAuthenticatorType'] == 'client-secret' &&
           ! d.key?('name')
          begin
            secret_output = kcadm('get', "clients/#{d['id']}/client-secret", realm)
          rescue
            Puppet.debug("Unable to get clients/#{d['id']}/client-secret")
            secret_output = "{}"
          end
          secret_data = JSON.parse(secret_output)
          secret = secret_data['value']
        else
          secret = nil
        end
        client = {}
        client[:ensure] = :present
        client[:id] = d['id']
        client[:client_id] = d['clientId']
        client[:realm] = realm
        client[:name] = "#{client[:client_id]} on #{client[:realm]}"
        type_properties.each do |property|
          next unless d.key?(camelize(property))
          value = d[camelize(property)]
          if property == :secret
            value = secret
          end
          if !!value == value
            value = value.to_s.to_sym
          end
          client[property.to_sym] = value
        end
        clients << new(client)
      end
    end
    clients
  end

  def self.prefetch(resources)
    clients = instances
    resources.keys.each do |name|
      if provider = clients.find { |c| c.client_id == resources[name][:client_id] && c.realm == resources[name][:realm] }
        resources[name].provider = provider
      end
    end
  end

  def create
    fail("Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    data = {}
    data[:id] = resource[:id]
    data[:clientId] = resource[:client_id]
    data[:secret] = resource[:secret] if resource[:secret]
    type_properties.each do |property|
      if resource[property.to_sym]
        data[camelize(property)] = resource[property.to_sym]
      end
    end

    t = Tempfile.new('keycloak_client')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', 'clients', resource[:realm], t.path)
    rescue Exception => e
      raise Puppet::Error, "kcadm create client failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    begin
      kcadm('delete', "clients/#{resource[:id]}")
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
      data[:clientId] = resource[:client_id]
      type_properties.each do |property|
        if @property_flush[property.to_sym]
          data[camelize(property)] = resource[property.to_sym]
        end
      end

      t = Tempfile.new('keycloak_client')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "clients/#{resource[:id]}", resource[:realm], t.path)
      rescue Exception => e
        raise Puppet::Error, "kcadm update client failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end

end
