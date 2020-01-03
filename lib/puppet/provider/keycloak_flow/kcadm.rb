require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_flow).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def self.instances
    flows = []
    realms.each do |realm|
      output = kcadm('get', 'authentication/flows', realm)
      Puppet.debug("#{realm} flows: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get flows')
        data = []
      end

      data.each do |d|
        if d['builtIn']
          Puppet.debug("Skipping builtIn flow #{d['alias']}")
          next
        end
        flow = {}
        flow[:ensure] = :present
        flow[:id] = d['id']
        flow[:alias] = d['alias']
        flow[:realm] = realm
        flow[:description] = d['description']
        flow[:provider_id] = d['providerId']
        flow[:name] = "#{flow[:alias]} on #{flow[:realm]}"
        flows << new(flow)
      end
    end
    flows
  end

  def self.prefetch(resources)
    flows = instances
    resources.keys.each do |name|
      provider = flows.find { |c| c.alias == resources[name][:alias] && c.realm == resources[name][:realm] }
      if provider
        resources[name].provider = provider
      end
    end
  end

  def create
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?

    data = {}
    data[:id] = resource[:id]
    data[:alias] = resource[:alias]
    data[:description] = resource[:description]
    data[:providerId] = resource[:provider_id]
    data[:topLevel] = true
    t = Tempfile.new('keycloak_flow')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      output = kcadm('create', 'authentication/flows', resource[:realm], t.path)
      Puppet.debug("create flow output: #{output}")
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm create flow failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    raise(Puppet::Error, "Realm is mandatory for #{resource.type} #{resource.name}") if resource[:realm].nil?
    begin
      kcadm('delete', "authentication/flows/#{id}", resource[:realm])
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm delete flow failed\nError message: #{e.message}"
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
      data[:id] = resource[:id]
      data[:alias] = resource[:alias]
      data[:description] = resource[:description]
      data[:providerId] = resource[:provider_id]
      data[:topLevel] = true
      t = Tempfile.new('keycloak_flow')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "authentication/flows/#{id}", resource[:realm], t.path)
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update flow failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
