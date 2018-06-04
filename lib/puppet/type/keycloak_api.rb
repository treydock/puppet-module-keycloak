Dir[File.dirname(__FILE__) + '/keycloak*.rb'].each do |file|
  next if file == __FILE__
  next if File.basename(file) == 'keycloak_conn_validator.rb'
  require file
end

Puppet::Type.newtype(:keycloak_api) do
  newparam(:name, :namevar => true) do
    desc 'Keycloak API config'
  end

  newparam(:install_base) do
  end

  newparam(:server) do
    defaultto('http://localhost:8080/auth')
  end

  newparam(:realm) do
    defaultto('master')
  end

  newparam(:user) do
    defaultto('admin')
  end

  newparam(:password) do
    defaultto('changeme')
  end

  newparam(:use_wrapper, :boolean => true) do
    newvalues(:true, :false)
    defaultto :false
  end

  def generate
    [
      :keycloak_client_template,
      :keycloak_client,
      :keycloak_ldap_mapper,
      :keycloak_ldap_user_provider,
      :keycloak_protocol_mapper,
      :keycloak_realm,
    ].each do |res_type|
      provider_class = Puppet::Type.type(res_type).provider(:kcadm)
      provider_class.install_base = self[:install_base]
      provider_class.server = self[:server]
      provider_class.realm = self[:realm]
      provider_class.user = self[:user]
      provider_class.password = self[:password]
      provider_class.use_wrapper = self[:use_wrapper]
    end

    []
  end

end
