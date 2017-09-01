require File.expand_path(File.join(File.dirname(__FILE__), '..', 'provider', 'keycloak_api'))

Puppet::Type.newtype(:keycloak_realm) do
  @doc = %q{
  
  }

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

  [
    {:n => :display_name, :d => nil},
    {:n => :display_name_html, :d => nil},
    {:n => :login_theme, :d => 'keycloak'},
    {:n => :account_theme, :d => 'keycloak'},
    {:n => :admin_theme, :d => 'keycloak'},
    {:n => :email_theme, :d => 'keycloak'},
  ].each do |p|
    newproperty(p[:n]) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"

      unless p[:d].nil?
        defaultto do
          if p[:d] == :name
            @resource[:name]
          else
            p[:d]
          end
        end
      end
    end
  end

  [
    {:n => :enabled, :d => true },
    {:n => :remember_me, :d => false },
    {:n => :login_with_email_allowed, :d => true },
  ].each do |p|
    newproperty(p[:n], :boolean => true) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
      newvalues(:true, :false)
      defaultto p[:d]
    end
  end

  autorequire(:keycloak_validator) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Keycloak_conn_validator'
        requires << resource.name
      end
    end
    requires
  end

  autorequire(:file) do
    [ 'kcadm-wrapper.sh' ]
  end

end
