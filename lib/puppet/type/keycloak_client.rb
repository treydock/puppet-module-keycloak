require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_client) do
  desc <<-DESC
Manage Keycloak clients
@example Add a OpenID Connect client
  keycloak_client { 'www.example.com':
    ensure          => 'present',
    realm           => 'test',
    redirect_uris   => [
      "https://www.example.com/oidc",
      "https://www.example.com",
    ],
    client_template => 'oidc-clients',
    secret          => 'supersecret',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The client name'
  end

  newparam(:client_id, :namevar => true) do
    desc 'clientId'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:id) do
    desc 'Id'
    defaultto do
      @resource[:client_id]
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

  newproperty(:client_authenticator_type) do
    desc "clientAuthenticatorType"
    defaultto 'client-secret'
  end

  newproperty(:client_template) do
    desc 'clientTemplate'
  end

  newproperty(:enabled, :boolean => true) do
    desc "enabled"
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:direct_access_grants_enabled, :boolean => true) do
    desc "enabled"
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:public_client, :boolean => true) do
    desc "enabled"
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:redirect_uris, :array_matching => :all, :parent => PuppetX::Keycloak::ArrayProperty) do
    desc "redirectUris"
    defaultto []
  end

  newproperty(:web_origins, :array_matching => :all, :parent => PuppetX::Keycloak::ArrayProperty) do
    desc "webOrigins"
    defaultto []
  end

  autorequire(:keycloak_client_template) do
    [ self[:client_template] ]
  end

  autorequire(:keycloak_protocol_mapper) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Keycloak_protocol_mapper'
        if resource[:client_template] == self[:client_template]
          requires << resource.name
        end
      end
    end
    requires
  end

  def self.title_patterns
    [
      [
        /^((\S+) on (\S+))$/,
        [
          [:name],
          [:client_id],
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
