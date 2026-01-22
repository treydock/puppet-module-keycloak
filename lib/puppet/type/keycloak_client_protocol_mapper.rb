# frozen_string_literal: true

require_relative '../provider/keycloak_api'
require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_client_protocol_mapper) do
  desc <<-DESC
Manage Keycloak protocol mappers
@example Add email protocol mapper to test.example.com client in realm test
  keycloak_client_protocol_mapper { "email for test.example.com on test":
    claim_name     => 'email',
    user_attribute => 'email',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The protocol mapper name'
  end

  newparam(:id) do
    desc 'Id.'
  end

  newparam(:resource_name, namevar: true) do
    desc 'The protocol mapper name. Defaults to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:client, namevar: true) do
    desc 'client'
  end

  newparam(:realm, namevar: true) do
    desc 'realm'
  end

  newproperty(:protocol) do
    desc 'protocol'
    defaultto('openid-connect')
    newvalues('openid-connect', 'saml')
    munge { |v| v }
  end

  newparam(:type) do
    desc <<-DESC
    protocolMapper.

    Default is `oidc-usermodel-property-mapper` for `protocol` `openid-connect` and
    `saml-user-property-mapper` for `protocol` `saml`.
    DESC
    newvalues(
      'oidc-usermodel-client-role-mapper',
      'oidc-usermodel-property-mapper',
      'oidc-full-name-mapper',
      'oidc-group-membership-mapper',
      'oidc-audience-mapper',
      'saml-user-property-mapper',
      'saml-role-list-mapper',
      %r{script-.+},
    )
    defaultto do
      case @resource[:protocol]
      when 'openid-connect'
        'oidc-usermodel-property-mapper'
      when 'saml'
        'saml-user-property-mapper'
      else
        nil
      end
    end
    munge { |v| v }
  end

  newproperty(:user_attribute) do
    desc 'user.attribute. Default to `resource_name` for `type` `oidc-usermodel-property-mapper` or `saml-user-property-mapper`'
    defaultto do
      if @resource[:type] == 'oidc-usermodel-property-mapper' || @resource[:type] == 'saml-user-property-mapper'
        @resource[:resource_name]
      else
        nil
      end
    end
  end

  newproperty(:json_type_label) do
    desc 'json.type.label. Default to `String` for `type` `oidc-usermodel-property-mapper` and `oidc-group-membership-mapper`.'
    defaultto do
      if ['oidc-usermodel-property-mapper', 'oidc-group-membership-mapper'].include?(@resource[:type])
        'String'
      else
        nil
      end
    end
  end

  newproperty(:full_path, boolean: true) do
    desc 'full.path. Default to `false` for `type` `oidc-group-membership-mapper`.'
    newvalues(:true, :false)
    defaultto do
      if @resource[:type] == 'oidc-group-membership-mapper'
        :false
      else
        nil
      end
    end
  end

  newproperty(:friendly_name) do
    desc 'friendly.name. Default to `resource_name` for `type` `saml-user-property-mapper`.'
    defaultto do
      if @resource[:type] == 'saml-user-property-mapper'
        @resource[:resource_name]
      else
        nil
      end
    end
  end

  newproperty(:attribute_name) do
    desc 'attribute.name Default to `resource_name` for `type` `saml-user-property-mapper`.'
    defaultto do
      if @resource[:type] == 'saml-user-property-mapper'
        @resource[:resource_name]
      else
        nil
      end
    end
  end

  newproperty(:claim_name) do
    desc 'claim.name'
  end

  newproperty(:id_token_claim, boolean: true) do
    desc 'id.token.claim. Default to `true` for `protocol` `openid-connect`.'
    newvalues(:true, :false)
    defaultto do
      if @resource['protocol'] == 'openid-connect'
        :true
      else
        nil
      end
    end
  end

  newproperty(:access_token_claim, boolean: true) do
    desc 'access.token.claim. Default to `true` for `protocol` `openid-connect`.'
    newvalues(:true, :false)
    defaultto do
      if @resource['protocol'] == 'openid-connect'
        :true
      else
        nil
      end
    end
  end

  newproperty(:userinfo_token_claim, boolean: true) do
    desc 'userinfo.token.claim. Default to `true` for `protocol` `openid-connect` except `type` of `oidc-audience-mapper`.'
    newvalues(:true, :false)
    defaultto do
      if @resource['protocol'] == 'openid-connect' && @resource['type'] != 'oidc-audience-mapper'
        :true
      else
        nil
      end
    end
  end

  newproperty(:attribute_nameformat) do
    desc 'attribute.nameformat'
    validate do |v|
      unless [:basic, :uri, :unspecified].include?(v.downcase.to_sym)
        raise ArgumentError, 'attribute_nameformat must be one of basic, uri, or unspecified'
      end
    end
    munge do |v|
      v.downcase.to_sym
    end
  end

  newproperty(:usermodel_client_role_mapping_client_id) do
    desc 'usermodel.clientRoleMapping.clientId for `type` `oidc-usermodel-client-role-mapper`'
  end

  newproperty(:single, boolean: true) do
    desc 'single. Default to `false` for `type` `saml-role-list-mapper`.'
    newvalues(:true, :false)
    defaultto do
      if ['saml-role-list-mapper'].include?(@resource['type'])
        :false
      else
        nil
      end
    end
  end

  newproperty(:multivalued, boolean: true) do
    desc 'multivalued'
    newvalues(:true, :false)
  end

  newproperty(:included_client_audience) do
    desc 'included.client.audience Required for `type` of `oidc-audience-mapper`'
  end

  autorequire(:keycloak_client) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.instance_of?(Puppet::Type::Keycloak_client)

      if resource[:client_id] == self[:client]
        requires << resource.name
      end
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
          [:client],
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
    oidc_types = [
      'oidc-usermodel-client-role-mapper',
      'oidc-usermodel-property-mapper',
      'oidc-full-name-mapper',
      'oidc-group-membership-mapper',
      'oidc-audience-mapper'
    ]
    if self[:protocol] == 'openid-connect' && !oidc_types.include?(self[:type]) && self[:type] !~ %r{script-.+}
      raise Puppet::Error, "type #{self[:type]} is not valid for protocol openid-connect"
    end
    if self[:protocol] == 'saml' && !['saml-user-property-mapper', 'saml-role-list-mapper'].include?(self[:type]) && self[:type] !~ %r{script-.+}
      raise Puppet::Error, "type #{self[:type]} is not valid for protocol saml"
    end
    if self[:friendly_name] && self[:type] !~ %r{(saml-user-property-mapper|script.+)}
      raise Puppet::Error, "friendly_name is not valid for type #{self[:type]}"
    end
    if self[:attribute_name] && self[:protocol] != 'saml'
      raise Puppet::Error, "attribute_name is not valid for type #{self[:type]}"
    end
    if self[:attribute_nameformat] && self[:protocol] != 'saml'
      raise Puppet::Error, "attribute_nameformat is not valid for protocol #{self[:protocol]}"
    end
    if self[:single] && self[:type] !~ %r{(saml-role-list-mapper|script-.+)}
      raise Puppet::Error, "single is not valid for type #{self[:type]}"
    end
    if self[:type] == 'oidc-audience-mapper' && self[:included_client_audience].nil?
      raise Puppet::Error, 'included_client_audience is required for oidc-audience-mapper'
    end
    if self[:usermodel_client_role_mapping_client_id] && self[:type] != 'oidc-usermodel-client-role-mapper'
      raise Puppet::Error, 'usermodel_client_role_mapping_client_id is only valid for type=oidc-usermodel-client-role-mapper'
    end
  end
end
