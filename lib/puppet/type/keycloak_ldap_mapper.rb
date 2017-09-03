require File.expand_path(File.join(File.dirname(__FILE__), '..', 'provider', 'keycloak_api'))

Puppet::Type.newtype(:keycloak_ldap_mapper) do
  @doc = %q{
  
  }

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The LDAP user provider name'
  end

  newparam(:id) do
    desc 'Id'
    defaultto do
      Puppet::Provider::Keycloak_API.name_uuid(@resource[:name])
    end
  end

  newparam(:resource_name) do
    desc 'The LDAP mapper name'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:type) do
    desc 'providerId'
    newvalues('user-attribute-ldap-mapper', 'full-name-ldap-mapper')
    defaultto 'user-attribute-ldap-mapper'
    munge { |v| v }
  end

  newparam(:realm, :namevar => true) do
    desc 'realm'
  end

  newparam(:ldap, :namevar => true) do
    desc 'parentId'
  end

  [
    {:n => :ldap_attribute, :d => nil},
    {:n => :user_model_attribute, :d => nil},
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

  newproperty(:is_mandatory_in_ldap) do
    desc 'is.mandatory.in.ldap'
    defaultto do
      if @resource[:type] == 'full-name-ldap-mapper'
        nil
      else
        :false
      end
    end
  end

  [
    {:n => :read_only, :d => :true},
    {:n => :write_only, :d => :false},
  ].each do |p|
    newproperty(p[:n], :boolean => true) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
      newvalues(:true, :false)
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
    [ self[:realm] ]
  end

  autorequire(:keycloak_ldap_user_provider) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Keycloak_ldap_user_provider'
        if "#{resource[:resource_name]}-#{resource[:realm]}" == self[:ldap]
          requires << resource.name
        end
      end
    end
    requires
  end

  def self.title_patterns
    [
      [
        /^((.+) for (\S+) on (\S+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :resource_name, lambda{|x| x} ],
          [ :ldap, lambda{|x| x} ],
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
