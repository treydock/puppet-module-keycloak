require_relative '../../puppet_x/keycloak/type'
require_relative '../../puppet_x/keycloak/array_property'

Puppet::Type.newtype(:keycloak_sssd_user_provider) do
  desc <<-DESC
Manage Keycloak SSSD user providers
@example Add SSSD user provider to test realm
  keycloak_sssd_user_provider { 'SSSD on test':
    ensure => 'present',
  }
  DESC

  extend PuppetX::Keycloak::Type
  add_autorequires

  ensurable

  newparam(:name, namevar: true) do
    desc 'The SSSD user provider name'
  end

  newparam(:resource_name) do
    desc 'The SSSD user provider name. Defaults to `name`.'
    defaultto do
      @resource[:name]
    end
  end

  newparam(:id) do
    desc 'Id. Defaults to "`resource_name`-`realm`"'
    defaultto do
      "#{@resource[:resource_name]}-#{@resource[:realm]}"
    end
  end

  newparam(:realm, namevar: true) do
    desc 'parentId'
  end

  newproperty(:enabled, boolean: true) do
    desc 'enabled'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:priority) do
    desc 'priority'
    defaultto '0'
  end

  newproperty(:cache_policy) do
    desc 'cachePolicy'
    newvalues('DEFAULT', 'EVICT_DAILY', 'EVICT_WEEKLY', 'MAX_LIFESPAN', 'NO_CACHE')
    defaultto 'DEFAULT'
  end

  newproperty(:eviction_day) do
    desc 'evictionDay'
  end

  newproperty(:eviction_hour) do
    desc 'evictionHour'
  end

  newproperty(:eviction_minute) do
    desc 'evictionMinute'
  end

  newproperty(:max_lifespan) do
    desc 'maxLifespan'
  end

  def self.title_patterns
    [
      [
        %r{^((\S+) on (\S+))$},
        [
          [:name],
          [:resource_name],
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
    if ['EVICT_DAILY', 'EVICT_WEEKLY'].include?(self[:cache_policy].to_s) && self[:eviction_hour].nil?
      raise Puppet::Error, 'cache_policy EVICT_DAILY and EVICT_WEEKLY require eviction_hour'
    end
    if ['EVICT_DAILY', 'EVICT_WEEKLY'].include?(self[:cache_policy].to_s) && self[:eviction_minute].nil?
      raise Puppet::Error, 'cache_policy EVICT_DAILY and EVICT_WEEKLY require eviction_minute'
    end
    if !['EVICT_DAILY', 'EVICT_WEEKLY'].include?(self[:cache_policy].to_s) && !self[:eviction_hour].nil?
      raise Puppet::Error, 'eviction_hour is only valid for cache_policy EVICT_DAILY and EVICT_WEEKLY'
    end
    if !['EVICT_DAILY', 'EVICT_WEEKLY'].include?(self[:cache_policy].to_s) && !self[:eviction_minute].nil?
      raise Puppet::Error, 'eviction_minute is only valid for cache_policy EVICT_DAILY and EVICT_WEEKLY'
    end
    if self[:cache_policy].to_s == 'EVICT_WEEKLY' && self[:eviction_day].nil?
      raise Puppet::Error, 'cache_policy EVICT_WEEKLY requires eviction_hour'
    end
    if self[:cache_policy].to_s != 'EVICT_WEEKLY' && !self[:eviction_day].nil?
      raise Puppet::Error, 'eviction_day is only valid with cache_policy EVICT_WEEKLY'
    end
    if self[:cache_policy].to_s == 'MAX_LIFESPAN' && self[:max_lifespan].nil?
      raise Puppet::Error, 'cache_policy MAX_LIFESPAN requires max_lifespan'
    end
    if self[:cache_policy].to_s != 'MAX_LIFESPAN' && !self[:max_lifespan].nil?
      raise Puppet::Error, 'max_lifespan is only valid with cache_policy MAX_LIFESPAN'
    end
  end
end
