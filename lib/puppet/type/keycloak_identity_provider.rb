# frozen_string_literal: true

require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'
require_relative '../../puppet_x/keycloak/integer_property'

# needed for puppet >= 8
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:keycloak_identity_provider) do
  desc <<-DESC
Manage Keycloak identity providers
@example Add CILogon identity provider to test realm
  keycloak_identity_provider { 'cilogon on test':
    ensure                         => 'present',
    display_name                   => 'CILogon',
    provider_id                    => 'oidc',
    first_broker_login_flow_alias  => 'browser',
    client_id                      => 'cilogon:/client_id/foobar',
    client_secret                  => 'supersecret',
    user_info_url                  => 'https://cilogon.org/oauth2/userinfo',
    token_url                      => 'https://cilogon.org/oauth2/token',
    authorization_url              => 'https://cilogon.org/authorize',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The identity provider name'
  end

  newparam(:alias, namevar: true) do
    desc 'The identity provider name. Defaults to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:internal_id) do
    desc 'internalId. Defaults to "`alias`-`realm`"'
    defaultto do
      "#{@resource[:alias]}-#{@resource[:realm]}"
    end
  end

  newparam(:realm, namevar: true) do
    desc 'realm'
  end

  newparam(:no_client_secret_warning, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'set this to true, to not display the puppet warning that we cannot ensure the client_secret'
    defaultto :false
  end

  newproperty(:display_name) do
    desc 'displayName'
  end

  newparam(:provider_id) do
    desc 'providerId'
    newvalues('oidc', 'keycloak-oidc')
    defaultto 'oidc'
    munge { |v| v }
  end

  newproperty(:enabled, boolean: true) do
    desc 'enabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:update_profile_first_login_mode) do
    desc 'updateProfileFirstLoginMode'
    newvalues('on', 'off')
  end

  newproperty(:trust_email, boolean: true) do
    desc 'trustEmail'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:store_token, boolean: true) do
    desc 'storeToken'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:add_read_token_role_on_create, boolean: true) do
    desc 'addReadTokenRoleOnCreate'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:authenticate_by_default, boolean: true) do
    desc 'authenticateByDefault'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:link_only, boolean: true) do
    desc 'linkOnly'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:gui_order, parent: PuppetX::Keycloak::IntegerProperty) do
    desc 'guiOrder'
    munge { |v| v.to_s }
  end

  newproperty(:first_broker_login_flow_alias) do
    desc 'firstBrokerLoginFlowAlias'
    defaultto 'first broker login'
    munge { |v| v }
  end

  newproperty(:post_broker_login_flow_alias) do
    desc 'postBrokerLoginFlowAlias'
    munge { |v| v }
  end

  newproperty(:sync_mode) do
    desc 'syncMode'
    defaultto 'IMPORT'
    newvalues('IMPORT', 'LEGACY', 'FORCE')
    munge { |v| v }
  end

  # BEGIN: oidc

  newproperty(:hide_on_login, boolean: true) do
    desc 'hideOnLogin'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:user_info_url) do
    desc 'userInfoUrl'
    munge { |v| v }
  end

  newproperty(:validate_signature, boolean: true) do
    desc 'validateSignature'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:client_id) do
    desc 'clientId'
  end

  newproperty(:client_secret) do
    desc "clientSecret.
         Puppet has no way to check current value and will therefore emit a warning
         which can be suppressed by setting no_client_secret_warning to true"

    def insync?(is)
      if is =~ %r{^\*+$}
        Puppet.warning("Parameter 'client_secret' is set and Puppet has no way to check current value") unless @resource[:no_client_secret_warning]
        true
      else
        false
      end
    end

    def change_to_s(currentvalue, _newvalue)
      if currentvalue == :absent
        'created client_secret'
      else
        'changed client_secret'
      end
    end

    def is_to_s(_currentvalue) # rubocop:disable Style/PredicateName
      '[old client_secret redacted]'
    end

    def should_to_s(_newvalue)
      '[new client_secret redacted]'
    end
  end

  newproperty(:client_auth_method) do
    desc 'clientAuthMethod'
    newvalues('client_secret_post', 'client_secret_basic', 'client_secret_jwt', 'private_key_jwt')
    defaultto('client_secret_post')
    munge { |v| v.to_s }
  end

  newproperty(:token_url) do
    desc 'tokenUrl'
  end

  newproperty(:ui_locales, boolean: true) do
    desc 'uiLocales'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:backchannel_supported, boolean: true) do
    desc 'backchannelSupported'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:use_jwks_url, boolean: true) do
    desc 'useJwksUrl'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:jwks_url) do
    desc 'jwksUrl'
    munge { |v| v }
  end

  newproperty(:login_hint, boolean: true) do
    desc 'loginHint'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:authorization_url) do
    desc 'authorizationUrl'
  end

  newproperty(:disable_user_info, boolean: true) do
    desc 'disableUserInfo'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:logout_url) do
    desc 'logoutUrl'
  end

  newproperty(:issuer) do
    desc 'issuer'
  end

  newproperty(:default_scope) do
    desc 'default_scope'
  end

  newproperty(:prompt) do
    desc 'prompt'
    newvalues('none', 'consent', 'login', 'select_account')
    munge { |v| v }
  end

  newproperty(:allowed_clock_skew) do
    desc 'allowedClockSkew'
  end

  newproperty(:forward_parameters) do
    desc 'forwardParameters'
  end

  # END: oidc

  def self.title_patterns
    [
      [
        %r{^((\S+) on (\S+))$},
        [
          [:name],
          [:alias],
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

  validate do
    if self[:realm].nil?
      raise Puppet::Error, 'realm is required'
    end

    if self[:ensure].to_s == 'present' && ['oidc', 'keycloak-oidc'].include?(self[:provider_id])
      if self[:authorization_url].nil?
        raise Puppet::Error, 'authorization_url is required'
      end
      if self[:token_url].nil?
        raise Puppet::Error, 'token_url is required'
      end
      if self[:client_id].nil?
        raise Puppet::Error, 'client_id is required'
      end
      if self[:client_secret].nil?
        raise Puppet::Error, 'client_secret is required'
      end
    end
  end

  autorequire(:keycloak_flow) do
    requires = []
    catalog.resources.each do |resource|
      next unless resource.instance_of?(Puppet::Type::Keycloak_flow)
      next if self[:realm] != resource[:realm]

      if self[:first_broker_login_flow_alias] == resource[:alias]
        requires << resource.name
      end
      if self[:post_broker_login_flow_alias] == resource[:alias]
        requires << resource.name
      end
    end
    requires
  end
end
