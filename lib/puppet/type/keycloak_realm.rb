require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_realm) do
  desc <<-DESC
Manage Keycloak realms
@example Add a realm with a custom theme
  keycloak_realm { 'test':
    ensure                   => 'present',
    remember_me              => true,
    login_with_email_allowed => false,
    login_theme              => 'my_theme',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires(false)

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The realm name'
  end

  newparam(:id) do
    desc 'Id'
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:display_name) do
    desc 'displayName'
  end

  newproperty(:display_name_html) do
    desc 'displayNameHtml'
  end

  newproperty(:login_theme) do
    desc 'loginTheme'
    defaultto 'keycloak'
  end

  newproperty(:account_theme) do
    desc 'accountTheme'
    defaultto 'keycloak'
  end

  newproperty(:admin_theme) do
    desc 'adminTheme'
    defaultto 'keycloak'
  end

  newproperty(:email_theme) do
    desc 'emailTheme'
    defaultto 'keycloak'
  end

  newproperty(:enabled, :boolean => true) do
    desc 'enabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:remember_me, :boolean => true) do
    desc 'rememberMe'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:login_with_email_allowed, :boolean => true) do
    desc 'loginWithEmailAllowed'
    newvalues(:true, :false)
    defaultto :true
  end
end
