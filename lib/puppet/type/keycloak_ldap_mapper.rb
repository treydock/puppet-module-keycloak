# frozen_string_literal: true

require_relative '../provider/keycloak_api'
require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

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
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The LDAP mapper name'
  end

  newparam(:id) do
    desc 'Id.'
  end

  newparam(:resource_name) do
    desc 'The LDAP mapper name. Defaults to `name`'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:type) do
    desc 'providerId'
    newvalues('user-attribute-ldap-mapper', 'full-name-ldap-mapper', 'group-ldap-mapper', 'role-ldap-mapper')
    defaultto 'user-attribute-ldap-mapper'
    munge { |v| v }
  end

  newparam(:realm, namevar: true) do
    desc 'realm'
  end

  newparam(:ldap, namevar: true) do
    desc 'Name of parent `keycloak_ldap_user_provider` resource'
  end

  newparam(:parent_id) do
    desc 'parentId'
  end

  newproperty(:ldap_attribute) do
    desc 'ldap.attribute'
  end

  newproperty(:user_model_attribute) do
    desc 'user.model.attribute'
  end

  newproperty(:is_mandatory_in_ldap) do
    desc 'is.mandatory.in.ldap. Defaults to `false` unless `type` is `full-name-ldap-mapper`.'
    defaultto do
      if @resource[:type] == 'full-name-ldap-mapper'
        nil
      elsif !['group-ldap-mapper', 'role-ldap-mapper'].include?(@resource[:type])
        :false
      else
        nil
      end
    end
  end

  newproperty(:always_read_value_from_ldap, boolean: true) do
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

  newproperty(:read_only, boolean: true) do
    desc 'read.only'
    newvalues(:true, :false)
    defaultto do
      if !['group-ldap-mapper', 'role-ldap-mapper'].include?(@resource[:type])
        :true
      else
        nil
      end
    end
  end

  newproperty(:write_only, boolean: true) do
    desc 'write.only.  Defaults to `false` if `type` is `full-name-ldap-mapper`.'
    newvalues(:true, :false)
    defaultto do
      if @resource[:type] == 'full-name-ldap-mapper'
        :false
      else
        nil
      end
    end
  end

  newproperty(:mode) do
    desc 'mode, only for `type` of `group-ldap-mapper` and `role-ldap-mapper`'
    newvalues('READ_ONLY', 'LDAP_ONLY')
    defaultto do
      if ['group-ldap-mapper', 'role-ldap-mapper'].include?(@resource[:type])
        'READ_ONLY'
      else
        nil
      end
    end
    munge { |v| v }
  end

  newproperty(:membership_attribute_type) do
    desc 'membership.attribute.type, only for `type` of `group-ldap-mapper` and `role-ldap-mapper`'
    newvalues('DN', 'UID')
    defaultto do
      if ['group-ldap-mapper', 'role-ldap-mapper'].include?(@resource[:type])
        'DN'
      else
        nil
      end
    end
    munge { |v| v }
  end

  newproperty(:user_roles_retrieve_strategy) do
    desc 'user.roles.retrieve.strategy, only for `type` of `group-ldap-mapper` and `role-ldap-mapper`'
    newvalues('LOAD_GROUPS_BY_MEMBER_ATTRIBUTE', 'GET_GROUPS_FROM_USER_MEMBEROF_ATTRIBUTE', 'LOAD_GROUPS_BY_MEMBER_ATTRIBUTE_RECURSIVELY',
              'LOAD_ROLES_BY_MEMBER_ATTRIBUTE', 'GET_ROLES_FROM_USER_MEMBEROF_ATTRIBUTE', 'LOAD_ROLES_BY_MEMBER_ATTRIBUTE_RECURSIVELY')
    defaultto do
      case @resource[:type]
      when 'group-ldap-mapper'
        'LOAD_GROUPS_BY_MEMBER_ATTRIBUTE'
      when 'role-ldap-mapper'
        'LOAD_ROLES_BY_MEMBER_ATTRIBUTE'
      else
        nil
      end
    end
    munge { |v| v }
  end

  newproperty(:group_name_ldap_attribute) do
    desc 'group.name.ldap.attribute, only for `type` of `group-ldap-mapper`'
    defaultto do
      if @resource[:type] == 'group-ldap-mapper'
        'cn'
      else
        nil
      end
    end
  end

  newproperty(:ignore_missing_groups, boolean: true) do
    desc 'ignore.missing.groups, only for `type` of `group-ldap-mapper`'
    newvalues(:true, :false)
    defaultto do
      if @resource[:type] == 'group-ldap-mapper'
        :false
      else
        nil
      end
    end
  end

  newproperty(:membership_user_ldap_attribute) do
    desc 'membership.user.ldap.attribute, only for `type` of `group-ldap-mapper` and `role-ldap-mapper`'
    defaultto do
      if ['group-ldap-mapper', 'role-ldap-mapper'].include?(@resource[:type])
        'uid'
      else
        nil
      end
    end
  end

  newproperty(:membership_ldap_attribute) do
    desc 'membership.ldap.attribute, only for `type` of `group-ldap-mapper` and `role-ldap-mapper`'
    defaultto do
      if ['group-ldap-mapper', 'role-ldap-mapper'].include?(@resource[:type])
        'member'
      else
        nil
      end
    end
  end

  newproperty(:preserve_group_inheritance, boolean: true) do
    desc 'preserve.group.inheritance, only for `type` of `group-ldap-mapper`'
    newvalues(:true, :false)
    defaultto do
      if @resource[:type] == 'group-ldap-mapper'
        :true
      else
        nil
      end
    end
  end

  newproperty(:groups_dn) do
    desc 'groups.dn, only for `type` of `group-ldap-mapper`'
  end

  newproperty(:mapped_group_attributes) do
    desc 'mapped.group.attributes, only for `type` of `group-ldap-mapper`'
  end

  newproperty(:groups_ldap_filter) do
    desc 'groups.ldap.filter, only for `type` of `group-ldap-mapper`'
  end

  newproperty(:memberof_ldap_attribute) do
    desc 'memberof.ldap.attribute, only for `type` of `group-ldap-mapper` and `role-ldap-mapper`'
    defaultto do
      if ['group-ldap-mapper', 'role-ldap-mapper'].include?(@resource[:type])
        'memberOf'
      else
        nil
      end
    end
  end

  newproperty(:group_object_classes) do
    desc 'group.object.classes, only for `type` of `group-ldap-mapper`'
    defaultto do
      if @resource[:type] == 'group-ldap-mapper'
        'groupOfNames'
      else
        nil
      end
    end
  end

  newproperty(:drop_non_existing_groups_during_sync, boolean: true) do
    desc 'drop.non.existing.groups.during.sync, only for `type` of `group-ldap-mapper`'
    newvalues(:true, :false)
    defaultto do
      if @resource[:type] == 'group-ldap-mapper'
        :false
      else
        nil
      end
    end
  end

  newproperty(:roles_dn) do
    desc 'roles.dn, only for `type` of `role-ldap-mapper`'
  end

  newproperty(:role_name_ldap_attribute) do
    desc 'role.name.ldap.attribute, only for `type` of `role-ldap-mapper`'
    defaultto do
      if @resource[:type] == 'role-ldap-mapper'
        'cn'
      else
        nil
      end
    end
  end

  newproperty(:role_object_classes) do
    desc 'role.object.classes, only for `type` of `role-ldap-mapper`'
    defaultto do
      if @resource[:type] == 'role-ldap-mapper'
        'groupOfNames'
      else
        nil
      end
    end
  end

  newproperty(:roles_ldap_filter) do
    desc 'roles.ldap.filter, only for `type` of `role-ldap-mapper`'
  end

  newproperty(:use_realm_roles_mapping, boolean: true) do
    desc 'use.realm.roles.mapping, only for `type` of `role-ldap-mapper`'
    newvalues(:true, :false)
    defaultto do
      if @resource[:type] == 'role-ldap-mapper'
        :true
      else
        nil
      end
    end
  end

  newproperty(:client_id) do
    desc 'client.id, only for `type` of `role-ldap-mapper`'
  end

  autorequire(:keycloak_ldap_user_provider) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.class.to_s == 'Puppet::Type::Keycloak_ldap_user_provider'

      if self[:ldap] == resource[:resource_name] && self[:realm] == resource[:realm]
        requires << resource.name
      end
    end
    requires
  end

  autorequire(:keycloak_client) do
    requires = []
    # frozen_string_literal: true
    if self[:type] == 'role-ldap-mapper' && (self[:use_realm_roles_mapping].to_sym == :false)
      requires = [self[:client_id]]
    end
    requires
  end

  def self.title_patterns
    [
      [
        %r{^((.+) for (\S+) on (\S+))$},
        [
          [:name],
          [:resource_name],
          [:ldap],
          [:realm]
        ]
      ],
      [
        %r{(.*)},
        [
          [:name]
        ]
      ]
    ]
  end

  validate do
    required_properties = [
      :realm,
      :ldap
    ]
    required_properties.each do |property|
      if self[property].nil?
        raise Puppet::Error, "You must provide a value for #{property}"
      end
    end
    if self[:ensure] == :present
      if self[:type] == 'group-ldap-mapper' && self[:groups_dn].nil?
        raise Puppet::Error, 'Must define groups_dn for type group-ldap-mapper'
      end

      if self[:type] == 'role-ldap-mapper'
        if self[:roles_dn].nil?
          raise Puppet::Error, 'Must define roles_dn for type role-ldap-mapper'
        end
        if self[:use_realm_roles_mapping].to_sym == :false && self[:client_id].nil?
          raise Puppet::Error, 'Must define client_id when user_realm_roles_mapping'
        end
      end
    end
  end
end
