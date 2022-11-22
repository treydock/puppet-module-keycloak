# frozen_string_literal: true

require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_client_scope) do
  desc <<-DESC
Manage Keycloak client scopes
@example Define a OpenID Connect client scope in the test realm
  keycloak_client_scope { 'email on test':
    protocol => 'openid-connect',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The client scope name'
  end

  newparam(:resource_name, namevar: true) do
    desc 'The client scope name. Defaults to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:id) do
    desc 'Id. Defaults to `resource_name`.'
    defaultto do
      @resource[:resource_name]
    end
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

  newproperty(:consent_screen_text) do
    desc 'consent.screen.text'
  end

  newproperty(:display_on_consent_screen, boolean: true) do
    desc 'display.on.consent.screen'
    newvalues(:true, :false)
    defaultto :true
  end

  def self.title_patterns
    [
      [
        %r{^((\S+) on (\S+))$},
        [
          [:name],
          [:resource_name],
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
end
