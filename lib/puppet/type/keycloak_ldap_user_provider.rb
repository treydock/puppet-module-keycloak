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
    {:n => :bind_dn, :d => nil},
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

  newproperty(:bind_credential) do
    desc "bindCredential"

    def change_to_s(currentvalue, newvalue)
      if currentvalue == :absent
        return "created bind_credential"
      else
        return "changed bind_credential"
      end
    end

    def is_to_s( currentvalue )
      return '[old bind_credential redacted]'
    end
    def should_to_s( newvalue )
      return '[new bind_credential redacted]'
    end
  end

  [
    {:n => :import_enabled, :d => :true },
    {:n => :use_kerberos_for_password_authentication, :d => nil}
  ].each do |p|
    newproperty(p[:n], :boolean => true) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
      newvalues(:true, :false)
      unless p[:d].nil?
        defaultto p[:d]
      end
    end
  end

  [
    {:n => :user_object_classes, :d => ['inetOrgPerson', 'organizationalPerson']},
  ].each do |p|
    newproperty(p[:n], :array_matching => :all) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
      defaultto p[:d]

      def insync?(is)
        if is.is_a?(Array) and @should.is_a?(Array)
          is.sort == @should.sort
        else
          is == @should
        end
      end

      def change_to_s(currentvalue, newvalue)
        currentvalue = currentvalue.join(',') if currentvalue != :absent
        newvalue = newvalue.join(',')
        super(currentvalue, newvalue)
      end

      def is_to_s(currentvalue)
        if currentvalue.is_a?(Array)
          currentvalue.join(',')
        else
          currentvalue
        end
      end
      alias :should_to_s :is_to_s
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
          [:name],
          [:resource_name],
          [:realm],
        ],
      ],
      [
        /(.*)/,
        [
          [:name],
        ],
      ],
    ]
  end

  validate do
    if self[:use_kerberos_for_password_authentication] && self[:auth_type] == 'none'
      self.fail "use_kerberos_for_password_authentication is not valid for auth_type none"
    end
    if self[:bind_credential] && self[:auth_type] == 'none'
      self.fail "bind_credential is not valid for auth_type none"
    end
    if self[:bind_dn] && self[:auth_type] == 'none'
      self.fail "bind_dn is not valid for auth_type none"
    end
  end

end
