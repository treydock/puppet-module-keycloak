require File.expand_path(File.join(File.dirname(__FILE__), '..', 'provider', 'keycloak_api'))

Puppet::Type.newtype(:keycloak_protocol_mapper) do
  @doc = %q{
  
  }

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The protocol mapper name'
  end

  newparam(:id) do
    desc 'Id'
    defaultto do
      Puppet::Provider::Keycloak_API.name_uuid(@resource[:name])
    end
  end

  newparam(:resource_name, :namevar => true) do
    desc 'The protocol mapper name'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:client_template, :namevar => true) do
    desc 'client template'
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

  newparam(:type) do
    desc 'protocolMapper'
    newvalues('oidc-usermodel-property-mapper', 'oidc-full-name-mapper')
    defaultto 'oidc-usermodel-property-mapper'
    munge { |v| v }
  end

  [
    {:n => :user_attribute, :d => :name},
    {:n => :json_type_label, :d => 'String'},
  ].each do |p|
    newproperty(p[:n]) do
      desc "#{p[:n].to_s.gsub('_','.')}"
      defaultto do
        if @resource[:type] == 'oidc-full-name-mapper'
          nil
        else
          if p[:d] == :name
            @resource[:resource_name]
          else
            p[:d]
          end
        end
      end
    end
  end

  [
    {:n => :consent_text, :d => nil},
    {:n => :claim_name, :d => nil},
  ].each do |p|
    newproperty(p[:n]) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"

      unless p[:d].nil?
        defaultto do
          if p[:d] == :name
            @resource[:resource_name]
          else
            p[:d]
          end
        end
      end
    end
  end

  [
    {:n => :consent_required, :d => :true},
    {:n => :id_token_claim, :d => :true},
    {:n => :access_token_claim, :d => :true},
    {:n => :userinfo_token_claim, :d => :true},
  ].each do |p|
    newproperty(p[:n], :boolean => true) do
      desc "#{Puppet::Provider::Keycloak_API.camelize(p[:n])}"
      newvalues(:true, :false)
      unless p[:d].nil?
        defaultto p[:d]
      end
    end
  end

  autorequire(:keycloak_conn_validator) do
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

  autorequire(:keycloak_realm) do
    [ self[:realm] ]
  end

  autorequire(:keycloak_client_template) do
    self[:client_template]
  end

  def self.title_patterns
    [
      [
        /^((.+) for (\S+) on (\S+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :resource_name, lambda{|x| x} ],
          [ :client_template, lambda{|x| x} ],
          [ :realm, lambda{|x| x} ],
        ],
      ],
      [
        /(.*)/,
        [
          [ :name, lambda{|x| x} ],
        ],
      ],
    ]
  end

end
