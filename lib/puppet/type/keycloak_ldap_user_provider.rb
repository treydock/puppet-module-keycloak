require File.expand_path(File.join(File.dirname(__FILE__), '..', 'provider', 'keycloak_api'))

Puppet::Type.newtype(:keycloak_ldap_user_provider) do
  @doc = %q{
  
  }

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The LDAP user provider name'
  end

  newparam(:resource_name) do
    desc 'The LDAP user provider name'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:id) do
    desc 'Id'
    defaultto do
      "#{@resource[:resource_name]}-#{@resource[:realm]}"
    end
  end

  newparam(:realm, :namevar => true) do
    desc 'parentId'
  end

  newproperty(:auth_type) do
    desc 'authType'
    defaultto 'none'
    newvalues('none', 'simple')
    munge {|v| v }
  end

  newproperty(:edit_mode) do
    desc 'editMode'
    defaultto 'READ_ONLY'
    newvalues('READ_ONLY', 'WRITABLE', 'UNSYNCED')
    munge {|v| v }
  end

  newproperty(:vendor) do
    desc 'vendor'
    defaultto 'other'
    newvalues('ad', 'rhds', 'tivoli', 'eDirectory', 'other')
    munge {|v| v }
  end

  newproperty(:use_truststore_spi) do
    desc 'useTruststoreSpi'
    defaultto 'ldapsOnly'
    newvalues('always', 'ldapsOnly', 'never')
    munge {|v| v }
  end

  [
    {:n => :users_dn, :d => nil},
    {:n => :connection_url, :d => nil},
    {:n => :priority, :d => '0'},
    {:n => :batch_size_for_sync, :d => '1000'},
    {:n => :username_ldap_attribute, :d => 'uid'},
    {:n => :rdn_ldap_attribute, :d => 'uid'},
    {:n => :uuid_ldap_attribute, :d => 'entryUUID'},
  ].each do |p|
    newproperty(p[:n]) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"

      unless p[:d].nil?
        defaultto do
          if p[:d] == :name
            @resource[:resource_name]
          else
            p[:d]
          end
        end
      end
    end
  end

  [
    {:n => :import_enabled, :d => :true },
  ].each do |p|
    newproperty(p[:n], :boolean => true) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
      newvalues(:true, :false)
      defaultto p[:d]
    end
  end

  [
    {:n => :user_object_classes, :d => ['inetOrgPerson', 'organizationalPerson']},
  ].each do |p|
    newproperty(p[:n], :array_matching => :all) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
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
