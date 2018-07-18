require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_client_template) do
  desc <<-DESC
Manage Keycloak client templates
@example Define a OpenID Connect client template in the test realm
  keycloak_client_template { 'oidc-clients on test':
    protocol           => 'openid-connect',
    full_scope_allowed => true,
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The client template name'
  end

  newparam(:resource_name, :namevar => true) do
    desc 'The client template name'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:id) do
    desc 'Id'
    defaultto do
      @resource[:resource_name]
    end
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

  newproperty(:full_scope_allowed, :boolean => true) do
    desc "fullScopeAllowed"
    newvalues(:true, :false)
    defaultto :true
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
end
