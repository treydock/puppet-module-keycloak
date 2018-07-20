require File.expand_path(File.join(File.dirname(__FILE__), '..', 'provider', 'keycloak_api'))

Puppet::Type.newtype(:keycloak_ldap_mapper) do
  desc <<-DESC
Manage Keycloak LDAP attribute mappers
@example Add full name attribute mapping
  keycloak_ldap_mapper { 'full name for LDAP-test on test:
    ensure         => 'present',
    type           => 'full-name-ldap-mapper',
    ldap_attribute => 'gecos',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The LDAP mapper name'
  end

  newparam(:id) do
    desc 'Id. Defaults to UUID generated from `name`.'
    defaultto do
      Puppet::Provider::Keycloak_API.name_uuid(@resource[:name])
    end
  end

  newparam(:resource_name) do
    desc 'The LDAP mapper name. Defaults to `name`'
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

  newproperty(:ldap_attribute) do
    desc 'ldapAttribute'
  end

  newproperty(:user_model_attribute) do
    desc 'userModelAttribute'
  end

  newproperty(:is_mandatory_in_ldap) do
    desc 'is.mandatory.in.ldap. Defaults to `false` unless `type` is `full-name-ldap-mapper`.'
    defaultto do
      if @resource[:type] == 'full-name-ldap-mapper'
        nil
      else
        :false
      end
    end
  end

  newproperty(:always_read_value_from_ldap, :boolean => true) do
    desc 'always.read.value.from.ldap. Defaults to `true` if `type` is `user-attribute-ldap-mapper`.'
    newvalues(:true, :false)
    defaultto do
      if @resource[:type] == 'user-attribute-ldap-mapper'
        :true
      else
        nil
      end
    end
  end

  newproperty(:read_only, :boolean => true) do
    desc "readOnly"
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:write_only, :boolean => true) do
    desc "writeOnly"
    newvalues(:true, :false)
    defaultto :false
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
          [:name],
          [:resource_name],
          [:ldap],
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
end
