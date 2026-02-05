# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_flow_execution).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def self.instances
    executions = []
    realms.each do |realm|
      output = kcadm('get', 'authentication/flows', realm)
      Puppet.debug("#{realm} flows: #{output}")
      begin
        flows = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get flows')
        flows = []
      end

      flows.each do |f|
        if f['builtIn']
          Puppet.debug("Skipping builtIn flow #{f['alias']}")
          next
        end
        Puppet.debug("Evaluate flow #{f['alias']}")
        begin
          executions_output = kcadm('get', "authentication/flows/#{f['alias']}/executions", realm)
        rescue StandardError
          Puppet.notice("Unable to query flow #{f['alias']} executions")
          executions_output = '[]'
        end
        Puppet.debug("#{realm} flow executions: #{executions_output}")
        begin
          executions_data = JSON.parse(executions_output)
        rescue JSON::ParserError
          Puppet.debug('Unable to parse output from kcadm get flow executions')
          executions_data = []
        end
        levels = {}
        executions_data.each do |e|
          execution = {}
          flow_alias = nil
          execution[:ensure] = :present
          execution[:id] = e['id']
          execution[:requirement] = e['requirement']
          execution[:configurable] = e['configurable'].to_s.to_sym if e.key?('configurable')
          execution[:flow_alias] = f['alias']
          execution[:realm] = realm
          execution[:priority] = e['priority']
          execution[:display_name] = e['displayName'] if e.key?('displayName')
          if e['level'] != 0
            parent_level = levels.find { |k, _v| k == (e['level'] - 1) }
            execution[:flow_alias] = parent_level[1][-1] if parent_level.size > 1
          end
          execution[:provider_id] = e['providerId']
          if e['authenticationConfig'] =~ %r{^script-.+}
            execution[:provider_id] = e['authenticationConfig']
          end
          execution[:alias] = e['alias']
          execution[:name] = "#{execution[:provider_id]} under #{execution[:flow_alias]} on #{realm}"
          if e['authenticationFlow']
            flow_alias = e['displayName']
          end
          levels[e['level']] = [] unless levels.key?(e['level'])
          levels[e['level']] << flow_alias unless flow_alias.nil?
          if e['authenticationFlow']
            Puppet.debug("Skipping authentication flow #{e['displayName']} for keycloak_flow_execution provider")
            next
          end
          execution[:config_id] = e['authenticationConfig']
          if execution[:config_id]
            config_output = kcadm('get', "authentication/config/#{execution[:config_id]}", realm)
            Puppet.debug("#{realm} flow execution config: #{config_output}")
            begin
              config_data = JSON.parse(config_output)
            rescue JSON::ParserError
              Puppet.debug('Unable to parse output from kcadm get flow execution config')
              config_data = []
            end
            execution[:config] = config_data['config']
          end
          Puppet.debug("EXECUTION: #{execution}")
          executions << new(execution)
        end
      end
    end
    executions
  end

  def self.prefetch(resources)
    executions = instances
    resources.each_key do |name|
      provider = executions.find do |c|
        c.provider_id == resources[name][:provider_id] && c.flow_alias == resources[name][:flow_alias] && c.realm == resources[name][:realm]
      end
      if provider
        resources[name].provider = provider
      end
    end
  end

  def create
    data = {}
    data[:provider] = resource[:provider_id]
    data[:displayName] = resource[:display_name] if resource[:display_name]
    data[:configurable] = convert_property_value(resource[:configurable]) if resource[:configurable]
    data[:alias] = resource[:alias] if resource[:alias]
    data[:priority] = resource[:priority]
    t = Tempfile.new('keycloak_flow_execution')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      new_id = kcadm('create', "authentication/flows/#{resource[:flow_alias]}/executions/execution", resource[:realm], t.path, nil, true)
      Puppet.debug("create flow execution output: #{new_id}")
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm create flow execution failed\nError message: #{e.message}"
    end
    if resource[:requirement] != 'DISABLED'
      update_data = {
        id: new_id.strip,
        requirement: resource[:requirement],
        priority: resource[:priority],
      }
      tu = Tempfile.new('keycloak_flow_execution_update')
      tu.write(JSON.pretty_generate(update_data))
      tu.close
      Puppet.debug(IO.read(tu.path))
      begin
        output = kcadm('update', "authentication/flows/#{resource[:flow_alias]}/executions", resource[:realm], tu.path)
        Puppet.debug("update flow execution output: #{output}")
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm update flow execution failed\nError message: #{e.message}"
      end
    end
    if resource[:configurable] == :true && resource[:config]
      config_data = {}
      config_data[:alias] = resource[:alias] if resource[:alias]
      config_data[:config] = resource[:config]
      tc = Tempfile.new('keycloak_flow_execution_config')
      tc.write(JSON.pretty_generate(config_data))
      tc.close
      Puppet.debug(IO.read(tc.path))
      begin
        output = kcadm('create', "authentication/executions/#{new_id.strip}/config", resource[:realm], tc.path)
        Puppet.debug("create flow execution config output: #{output}")
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "kcadm create flow execution config failed\nError message: #{e.message}"
      end
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    begin
      kcadm('delete', "authentication/executions/#{id}", resource[:realm])
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm delete flow failed\nError message: #{e.message}"
    end

    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  type_properties.each do |prop|
    define_method "#{prop}=".to_sym do |value|
      @property_flush[prop] = value
    end
  end

  def flush
    unless @property_flush.empty?
      if @property_flush[:requirement] || @property_flush[:priority]
        data = {}
        data[:id] = id
        data[:requirement] = resource[:requirement]
        data[:priority] = resource[:priority]
        t = Tempfile.new('keycloak_flow_execution')
        t.write(JSON.pretty_generate(data))
        t.close
        Puppet.debug(IO.read(t.path))
        begin
          kcadm('update', "authentication/flows/#{resource[:flow_alias]}/executions", resource[:realm], t.path, nil, true)
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update flow execution failed\nError message: #{e.message}"
        end
      end
      if @property_flush[:config]
        config_data = {}
        config_data[:alias] = resource[:alias] if resource[:alias]
        config_data[:config] = resource[:config]
        if !config_id.nil? && config_id.to_s != 'absent'
          config_data[:id] = config_id
        end
        t = Tempfile.new('keycloak_flow_execution_config')
        t.write(JSON.pretty_generate(config_data))
        t.close
        Puppet.debug(IO.read(t.path))
        begin
          if config_id.nil? || config_id.to_s == 'absent'
            output = kcadm('create', "authentication/executions/#{id}/config", resource[:realm], t.path)
            Puppet.debug("create flow execution config output: #{output}")
          else
            kcadm('update', "authentication/config/#{config_id}", resource[:realm], t.path)
            Puppet.debug("update flow execution config output: #{output}")
          end
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update flow execution config failed\nError message: #{e.message}"
        end
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
