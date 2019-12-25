require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_client) do
  desc <<-DESC
Manage Keycloak clients
@example Add a OpenID Connect client
  keycloak_client { 'www.example.com':
    ensure                => 'present',
    realm                 => 'test',
    redirect_uris         => [
      "https://www.example.com/oidc",
      "https://www.example.com",
    ],
    default_client_scopes => ['profile','email'],
    secret                => 'supersecret',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The client name'
  end

  newparam(:client_id, namevar: true) do
    desc 'clientId. Defaults to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:id) do
    desc 'Id. Defaults to `client_id`'
    defaultto do
      @resource[:client_id]
    end
  end

  newparam(:realm, namevar: true) do
    desc 'realm'
  end

  newparam(:secret) do
    desc 'secret'

    def change_to_s(currentvalue, _newvalue)
      if currentvalue == :absent
        'created secret'
      else
        'changed secret'
      end
    end

    def is_to_s(_currentvalue) # rubocop:disable Style/PredicateName
      '[old secret redacted]'
    end

    def should_to_s(_newvalue)
      '[new secret redacted]'
    end
  end

  newproperty(:protocol) do
    desc 'protocol'
    defaultto('openid-connect')
    newvalues('openid-connect', 'saml')
    munge { |v| v }
  end

  newproperty(:client_authenticator_type) do
    desc 'clientAuthenticatorType'
    defaultto 'client-secret'
  end

  newproperty(:default_client_scopes, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'defaultClientScopes'
    defaultto []
  end

  newproperty(:optional_client_scopes, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'optionalClientScopes'
    defaultto []
  end

  newproperty(:full_scope_allowed, boolean: true) do
    desc 'fullScopeAllowed'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newproperty(:enabled, boolean: true) do
    desc 'enabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:standard_flow_enabled, boolean: true) do
    desc 'standardFlowEnabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:implicit_flow_enabled, boolean: true) do
    desc 'implicitFlowEnabled'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:direct_access_grants_enabled, boolean: true) do
    desc 'enabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:service_accounts_enabled, boolean: true) do
    desc 'serviceAccountsEnabled'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:public_client, boolean: true) do
    desc 'enabled'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:redirect_uris, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'redirectUris'
    defaultto []
  end

  newproperty(:web_origins, array_matching: :all, parent: PuppetX::Keycloak::ArrayProperty) do
    desc 'webOrigins'
    defaultto []
  end

  newproperty(:login_theme) do
    desc 'login_theme'
    defaultto 'absent'
  end

  newproperty(:access_token_lifespan) do
    desc 'access.token.lifespan'
  end

  autorequire(:keycloak_client_scope) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.class.to_s == 'Puppet::Type::Keycloak_client_scope'
      if self[:default_client_scopes].include?(resource[:resource_name])
        requires << resource.name
      end
      if self[:optional_client_scopes].include?(resource[:resource_name])
        requires << resource.name
      end
    end
    requires
  end

  autorequire(:keycloak_protocol_mapper) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.class.to_s == 'Puppet::Type::Keycloak_protocol_mapper'
      if self[:default_client_scopes].include?(resource[:client_scope])
        requires << resource.name
      end
      if self[:optional_client_scopes].include?(resource[:client_scope])
        requires << resource.name
      end
    end
    requires
  end

  def self.title_patterns
    [
      [
        %r{^((\S+) on (\S+))$},
        [
          [:name],
          [:client_id],
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
end
