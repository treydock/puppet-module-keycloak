require File.expand_path(File.join(File.dirname(__FILE__), '..', 'provider', 'keycloak_api'))

Puppet::Type.newtype(:keycloak_client_template) do
  @doc = %q{
  
  }

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The client template name'
  end

  newparam(:resource_name, :namevar => true) do
    desc 'The client template name'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:id) do
    desc 'Id'
    defaultto do
      @resource[:resource_name]
    end
  end

  newparam(:realm, :namevar => true) do
    desc 'realm'
  end

  newproperty(:protocol) do
    desc 'protocol'
    defaultto('openid-connect')
    newvalues('openid-connect', 'saml')
    munge { |v| v }
  end

  [
    {:n => :full_scope_allowed, :d => :true },
  ].each do |p|
    newproperty(p[:n], :boolean => true) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
      newvalues(:true, :false)
      defaultto p[:d]
    end
  end

  autorequire(:keycloak_conn_validator) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Keycloak_conn_validator'
        requires << resource.name
      end
    end
    requires
  end

  autorequire(:file) do
    [ 'kcadm-wrapper.sh' ]
  end

  autorequire(:keycloak_realm) do
    self[:realm]
  end

  def self.title_patterns
    [
      [
        /^((\S+) on (\S+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :resource_name, lambda{|x| x} ],
          [ :realm, lambda{|x| x} ],
        ],
      ],
      [
        /(.*)/,
        [
          [ :name, lambda{|x| x} ],
        ],
      ],
    ]
  end

end
