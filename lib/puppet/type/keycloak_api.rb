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

  def generate
    [
      :keycloak_realm,
      :keycloak_ldap_user_provider,
    ].each do |res_type|
      provider_class = Puppet::Type.type(res_type).provider(:kcadm)
      provider_class.install_base = self[:install_base]
      provider_class.server = self[:server]
      provider_class.realm = self[:realm]
      provider_class.user = self[:user]
      provider_class.password = self[:password]
    end

    []
  end

end
