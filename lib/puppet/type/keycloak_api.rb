# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/keycloak*.rb"].sort.each do |file|
  next if file == __FILE__
  next if File.basename(file) == 'keycloak_conn_validator.rb'

  require file
end

Puppet::Type.newtype(:keycloak_api) do
  desc <<-DESC
  Type that configures API connection parameters for other keycloak types that use the Keycloak API.
  @example Define API access
    keycloak_api { 'keycloak'
      install_dir  => '/opt/keycloak',
      server       => 'http://localhost:8080',
      realm        => 'master',
      user         => 'admin',
      password     => 'changeme',
    }
  DESC
  newparam(:name, namevar: true) do
    desc 'Keycloak API config'
  end

  newparam(:install_dir) do
    desc 'Install location of Keycloak'
    defaultto('/opt/keycloak')
  end

  newparam(:server) do
    desc 'Auth URL for Keycloak server'
    defaultto('http://localhost:8080')
  end

  newparam(:realm) do
    desc 'Realm for authentication'
    defaultto('master')
  end

  newparam(:user) do
    desc 'User for authentication'
    defaultto('admin')
  end

  newparam(:password) do
    desc 'Password for authentication'
    defaultto('changeme')
  end

  newparam(:use_wrapper, boolean: true) do
    desc 'Boolean that determines if kcadm_wrapper.sh should be used'
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:keycloak_user) do
    desc 'Keycloak user'
    defaultto('keycloak')
  end

  newparam(:keycloak_group) do
    desc 'Keycloak group'
    defaultto('keycloak')
  end

  def generate
    kcadm_types = []
    Dir[File.join(File.dirname(__FILE__), '../provider/keycloak_*/kcadm.rb')].each do |file|
      type = File.basename(File.dirname(file))
      kcadm_types << type.to_sym
    end
    kcadm_types.each do |res_type|
      provider_class = Puppet::Type.type(res_type).provider(:kcadm)
      provider_class.install_dir = self[:install_dir]
      provider_class.server = self[:server]
      provider_class.realm = self[:realm]
      provider_class.user = self[:user]
      provider_class.password = self[:password]
      provider_class.use_wrapper = self[:use_wrapper]
      provider_class.keycloak_user = self[:keycloak_user]
      provider_class.keycloak_group = self[:keycloak_group]
    end

    []
  end
end
