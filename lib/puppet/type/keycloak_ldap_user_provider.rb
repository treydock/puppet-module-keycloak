require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'
require_relative '../../puppet_x/keycloak/integer_property'

Puppet::Type.newtype(:keycloak_ldap_user_provider) do
  desc <<-DESC
Manage Keycloak LDAP user providers
@example Add LDAP user provider to test realm
  keycloak_ldap_user_provider { 'LDAP on test':
    ensure             => 'present',
    users_dn           => 'ou=People,dc=example,dc=com',
    connection_url     => 'ldaps://ldap1.example.com:636 ldaps://ldap2.example.com:636',
    import_enabled     => false,
    use_truststore_spi => 'never',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The LDAP user provider name'
  end

  newparam(:resource_name) do
    desc 'The LDAP user provider name. Defaults to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:id) do
    desc 'Id'
    defaultto do
      @resource.provider.name_uuid(@resource[:name])
    end
  end

  newparam(:realm, namevar: true) do
    desc 'parentId'
  end

  newproperty(:enabled, boolean: true) do
    desc 'enabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:auth_type) do
    desc 'authType'
    defaultto 'none'
    newvalues('none', 'simple')
    munge { |v| v }
  end

  newproperty(:edit_mode) do
    desc 'editMode'
    defaultto 'READ_ONLY'
    newvalues('READ_ONLY', 'WRITABLE', 'UNSYNCED')
    munge { |v| v }
  end

  newproperty(:vendor) do
    desc 'vendor'
    defaultto 'other'
    newvalues('ad', 'rhds', 'tivoli', 'eDirectory', 'other')
    munge { |v| v }
  end

  newproperty(:use_truststore_spi) do
    desc 'useTruststoreSpi'
    defaultto 'ldapsOnly'
    newvalues('always', 'ldapsOnly', 'never')
    munge { |v| v }
  end

  newproperty(:users_dn) do
    desc 'usersDn'
  end

  newproperty(:connection_url) do
    desc 'connectionUrl'
  end

  newproperty(:priority) do
    desc 'priority'
    defaultto '0'
  end

  newproperty(:batch_size_for_sync) do
    desc 'batchSizeForSync'
    defaultto '1000'
  end

  newproperty(:username_ldap_attribute) do
    desc 'usernameLdapAttribute'
    defaultto 'uid'
  end

  newproperty(:rdn_ldap_attribute) do
    desc 'rdnLdapAttribute'
    defaultto 'uid'
  end

  newproperty(:uuid_ldap_attribute) do
    desc 'uuidLdapAttribute'
    defaultto 'entryUUID'
  end

  newproperty(:bind_dn) do
    desc 'bindDn'
  end

  newproperty(:bind_credential) do
    desc 'bindCredential'

    def insync?(is)
      if is =~ %r{^[\*]+$}
        Puppet.warning("Parameter 'bind_credential' is set and Puppet has no way to check current value")
        true
      else
        false
      end
    end

    def change_to_s(currentvalue, _newvalue)
      if currentvalue == :absent
        'created bind_credential'
      else
        'changed bind_credential'
      end
    end

    def is_to_s(_currentvalue) # rubocop:disable Style/PredicateName
      '[old bind_credential redacted]'
    end

    def should_to_s(_newvalue)
      '[new bind_credential redacted]'
    end
  end

  newproperty(:import_enabled, boolean: true) do
    desc 'importEnabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:use_kerberos_for_password_authentication, boolean: true) do
    desc 'useKerberosForPasswordAuthentication'
    newvalues(:true, :false)
  end

  newproperty(:user_object_classes, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'userObjectClasses'
    defaultto ['inetOrgPerson', 'organizationalPerson']
  end

  newproperty(:search_scope) do
    desc 'searchScope'
    newvalues(:one, :one_level, :subtree, '1', '2', 1, 2)
    munge do |v|
      if ['one', 'one_level'].include?(v.to_s)
        '1'
      elsif v.to_s == 'subtree'
        '2'
      else
        v.to_s
      end
    end
  end

  newproperty(:custom_user_search_filter) do
    desc 'customUserSearchFilter'
    newvalues(%r{.*}, :absent)
    defaultto(:absent)
    validate do |v|
      if v != :absent
        unless v.start_with?('(') && v.end_with?(')')
          raise ArgumentError, 'custom_user_search_filter must start with "(" and end with ")"'
        end
      end
    end
  end

  def self.title_patterns
    [
      [
        %r{^((\S+) on (\S+))$},
        [
          [:name],
          [:resource_name],
          [:realm],
        ],
      ],
      [
        %r{(.*)},
        [
          [:name],
        ],
      ],
    ]
  end

  newproperty(:trust_email, boolean: true) do
    desc 'trustEmail'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:full_sync_period, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'fullSyncPeriod'
    defaultto '-1'
    munge { |v| v.to_s }
  end

  newproperty(:changed_sync_period, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'changedSyncPeriod'
    defaultto '-1'
    munge { |v| v.to_s }
  end

  validate do
    if self[:use_kerberos_for_password_authentication] && self[:auth_type] == 'none'
      raise Puppet::Error, 'use_kerberos_for_password_authentication is not valid for auth_type none'
    end
    if self[:bind_credential] && self[:auth_type] == 'none'
      raise Puppet::Error, 'bind_credential is not valid for auth_type none'
    end
    if self[:bind_dn] && self[:auth_type] == 'none'
      raise Puppet::Error, 'bind_dn is not valid for auth_type none'
    end
  end
end
