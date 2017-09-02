require File.expand_path(File.join(File.dirname(__FILE__), '..', 'provider', 'keycloak_api'))

Puppet::Type.newtype(:keycloak_client) do
  @doc = %q{
  
  }

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The realm name'
  end

  newparam(:id) do
    desc 'Id'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:client_id, :namevar => true) do
    desc 'clientId'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:realm, :namevar => true) do
    desc 'realm'
  end

  newparam(:secret) do
    desc 'secret'

    def change_to_s(currentvalue, newvalue)
      if currentvalue == :absent
        return "created secret"
      else
        return "changed secret"
      end
    end

    def is_to_s( currentvalue )
      return '[old secret redacted]'
    end
    def should_to_s( newvalue )
      return '[new secret redacted]'
    end
  end

  newproperty(:protocol) do
    desc 'protocol'
    defaultto('openid-connect')
    newvalues('openid-connect', 'saml')
    munge { |v| v }
  end

  [
    {:n => :client_authenticator_type, :d => 'client-secret'},
    {:n => :client_template, :d => nil},
  ].each do |p|
    newproperty(p[:n]) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"

      unless p[:d].nil?
        defaultto do
          if p[:d] == :name
            @resource[:name]
          else
            p[:d]
          end
        end
      end
    end
  end

  [
    {:n => :enabled, :d => :true },
    {:n => :direct_access_grants_enabled, :d => :true},
    {:n => :public_client, :d => :false},
  ].each do |p|
    newproperty(p[:n], :boolean => true) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
      newvalues(:true, :false)
      defaultto p[:d]
    end
  end

  [
    {:n => :redirect_uris, :d => []},
    {:n => :web_origins, :d => []}
  ].each do |p|
    newproperty(p[:n], :array_matching => :all) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
      unless p[:d].nil?
        defaultto p[:d]
      end
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
          [ :client_id, lambda{|x| x} ],
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
