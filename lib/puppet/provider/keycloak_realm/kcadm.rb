require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_realm).provide(:kcadm, :parent => Puppet::Provider::Keycloak_API) do
  desc ""

  mk_resource_methods

  def self.instances
    realms = []

    output = kcadm('get', 'realms')
    Puppet.debug("Realms: #{output}")
    begin
      data = JSON.parse(output)
    rescue JSON::ParserError => e
      Puppet.debug('Unable to parse output from kcadm get realms')
      data = []
    end
    data.collect do |d|
      realm = {}
      realm[:ensure] = :present
      realm[:id] = d['id']
      realm[:name] = d['realm']
      type_properties.each do |property|
        value = d[camelize(property)]
        if !!value == value
          value = value.to_s.to_sym
        end
        realm[property.to_sym] = value
      end
      new(realm)
=begin
      new(
      :ensure                   => :present,
      :id                       => d['realm'],
      :name                     => d['realm'],
      :display_name             => d['displayName'],
      :display_name_html        => d['displayNameHtml'],
      :remember_me              => d['rememberMe'],
      :login_with_email_allowed => d['loginWithEmailAllowed'],
      :login_theme              => d['loginTheme'],
      :account_theme            => d['accountTheme'],
      :admin_theme              => d['adminTheme'],
      :email_theme              => d['emailTheme'],
      )
=end
    end
  end

  def self.prefetch(resources)
    realms = instances
    resources.keys.each do |name|
      if provider = realms.find { |realm| realm.name == name }
        resources[name].provider = provider
      end
    end
  end

  def create
    data = {}
    data[:id] = resource[:id]
    data[:realm] = resource[:name]
    type_properties.each do |property|
      if resource[property.to_sym]
        data[camelize(property)] = convert_property_value(resource[property.to_sym])
      end
    end
=begin
    data[:displayName] = resource[:display_name] if resource[:display_name]
    data[:displayNameHtml] = resource[:display_name_html] if resource[:display_name_html]
    data[:rememberMe] = resource[:remember_me] if resource[:remember_me]
    data[:loginWithEmailAllowed] = resource[:login_with_email_allowed] if resource[:login_with_email_allowed]
    data[:loginTheme] = resource[:login_theme] if resource[:login_theme]
    data[:accountTheme] = resource[:account_theme] if resource[:account_theme]
    data[:adminTheme] = resource[:admin_theme] if resource[:admin_theme]
    data[:emailTheme] = resource[:email_theme] if resource[:email_theme]
=end
    t = Tempfile.new('keycloak_realm')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      kcadm('create', 'realms', nil, t.path)
    rescue Exception => e
      raise Puppet::Error, "kcadm create realm failed\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    begin
      kcadm('delete', "realms/#{resource[:name]}")
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
      data = {}
      type_properties.each do |property|
        if @property_flush[property.to_sym] # || resource[property.to_sym]
          data[camelize(property)] = convert_property_value(resource[property.to_sym])
        end
      end
=begin
      data[:displayName] = resource[:display_name] if @property_flush[:display_name]
      data[:displayNameHtml] = resource[:display_name_html] if @property_flush[:display_name_html]
      data[:rememberMe] = resource[:remember_me] if @property_flush[:remember_me]
      data[:loginWithEmailAllowed] = resource[:login_with_email_allowed] if @property_flush[:login_with_email_allowed]
      data[:loginTheme] = resource[:login_theme] if @property_flush[:login_theme]
      data[:accountTheme] = resource[:account_theme] if @property_flush[:account_theme]
      data[:adminTheme] = resource[:admin_theme] if @property_flush[:admin_theme]
      data[:emailTheme] = resource[:email_theme] if @property_flush[:email_theme]
=end
      t = Tempfile.new('keycloak_realm')
      t.write(JSON.pretty_generate(data))
      t.close
      Puppet.debug(IO.read(t.path))
      begin
        kcadm('update', "realms/#{resource[:name]}", nil, t.path)
      rescue Exception => e
        raise Puppet::Error, "kcadm update realm failed\nError message: #{e.message}"
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end

end
