require_relative '../provider/keycloak_api'
require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_protocol_mapper) do
  desc <<-DESC
Manage Keycloak protocol mappers
@example Add email protocol mapper to oidc-client client template in realm test
  keycloak_protocol_mapper { "email for oidc-clients on test":
    consent_text   => '${email}',
    claim_name     => 'email',
    user_attribute => 'email',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The protocol mapper name'
  end

  newparam(:id) do
    desc 'Id. Defaults to UUID based on `name`.'
    defaultto do
      Puppet::Provider::Keycloak_API.name_uuid(@resource[:name])
    end
  end

  newparam(:resource_name, :namevar => true) do
    desc 'The protocol mapper name. Defaults to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:client_template, :namevar => true) do
    desc 'client template'
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

  newparam(:type) do
    desc <<-DESC
    protocolMapper.

    Default is `oidc-usermodel-property-mapper` for `protocol` `openid-connect` and
    `saml-user-property-mapper` for `protocol` `saml`.
    DESC
    newvalues(
      'oidc-usermodel-property-mapper',
      'oidc-full-name-mapper',
      'saml-user-property-mapper',
      'saml-role-list-mapper'
    )
    defaultto do
      if @resource[:protocol] == 'openid-connect'
        'oidc-usermodel-property-mapper'
      elsif @resource[:protocol] == 'saml'
        'saml-user-property-mapper'
      else
        nil
      end
    end
    munge { |v| v }
  end

  newproperty(:user_attribute) do
    desc "user.attribute. Default to `resource_name` for `type` `oidc-usermodel-property-mapper` or `saml-user-property-mapper`"
    defaultto do
      if @resource[:type] == 'oidc-usermodel-property-mapper' or @resource[:type] == 'saml-user-property-mapper'
        @resource[:resource_name]
      else
        nil
      end
    end
  end

  newproperty(:json_type_label) do
    desc "json.type.label. Default to `String` for `type` `oidc-usermodel-property-mapper`."
    defaultto do
      if @resource[:type] == 'oidc-usermodel-property-mapper'
        'String'
      else
        nil
      end
    end
  end

  newproperty(:friendly_name) do
    desc "friendly.name. Default to `resource_name` for `type` `saml-user-property-mapper`."
    defaultto do
      if @resource[:type] == 'saml-user-property-mapper'
        @resource[:resource_name]
      else
        nil
      end
    end
  end

  newproperty(:attribute_name) do
    desc "attribute.name Default to `resource_name` for `type` `saml-user-property-mapper`."
    defaultto do
      if @resource[:type] == 'saml-user-property-mapper'
        @resource[:resource_name]
      else
        nil
      end
    end
  end

  newproperty(:consent_text) do
    desc "consentText"
  end

  newproperty(:claim_name) do
    desc "claim.name"
  end

  newproperty(:consent_required, :boolean => true) do
    desc "consentRequired"
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:id_token_claim, :boolean => true) do
    desc "id.token.claim. Default to `true` for `protocol` `openid-connect`."
    newvalues(:true, :false)
    defaultto do
      if @resource['protocol'] == 'openid-connect'
        :true
      else
        nil
      end
    end
  end

  newproperty(:access_token_claim, :boolean => true) do
    desc "access.token.claim. Default to `true` for `protocol` `openid-connect`."
    newvalues(:true, :false)
    defaultto do
      if @resource['protocol'] == 'openid-connect'
        :true
      else
        nil
      end
    end
  end

  newproperty(:userinfo_token_claim, :boolean => true) do
    desc "userinfo.token.claim. Default to `true` for `protocol` `openid-connect`."
    newvalues(:true, :false)
    defaultto do
      if @resource['protocol'] == 'openid-connect'
        :true
      else
        nil
      end
    end
  end

  newproperty(:attribute_nameformat) do
    desc "attribute.nameformat"
    validate do |v|
      if ! [:basic, :uri, :unspecified].include?(v.downcase.to_sym)
        raise ArgumentError, "attribute_nameformat must be one of basic, uri, or unspecified"
      end
    end
    munge do |v|
      v.downcase.to_sym
    end
  end

  newproperty(:single, :boolean => true) do
    desc "single. Default to `false` for `type` `saml-role-list-mapper`."
    newvalues(:true, :false)
    defaultto do
      if @resource['type'] == 'saml-role-list-mapper'
        :false
      else
        nil
      end
    end
  end

  autorequire(:keycloak_client_template) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Keycloak_client_template'
        if resource[:resource_name] == self[:client_template]
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
          [:client_template],
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
    if self[:protocol] == 'openid-connect' && ! ['oidc-usermodel-property-mapper', 'oidc-full-name-mapper'].include?(self[:type])
      self.fail "type #{self[:type]} is not valid for protocol openid-connect"
    end
    if self[:protocol] == 'saml' && ! ['saml-user-property-mapper', 'saml-role-list-mapper'].include?(self[:type])
      self.fail "type #{self[:type]} is not valid for protocol saml"
    end
    if self[:friendly_name] && self[:type] != 'saml-user-property-mapper'
      self.fail "friendly_name is not valid for type #{self[:type]}"
    end
    if self[:attribute_name] && self[:protocol] != 'saml'
      self.fail "attribute_name is not valid for type #{self[:type]}"
    end
    if self[:attribute_nameformat] && self[:protocol] != 'saml'
      self.fail "attribute_nameformat is not valid for protocol #{self[:protocol]}"
    end
    if self[:single] && self[:type] != 'saml-role-list-mapper'
      self.fail "single is not valid for type #{self[:type]}"
    end
  end
end
