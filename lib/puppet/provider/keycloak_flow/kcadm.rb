# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'keycloak_api'))

Puppet::Type.type(:keycloak_flow).provide(:kcadm, parent: Puppet::Provider::KeycloakAPI) do
  desc ''

  mk_resource_methods

  def self.instances
    flows = []
    realms.each do |realm|
      output = kcadm('get', 'authentication/flows', realm)
      Puppet.debug("#{realm} flows: #{output}")
      begin
        data = JSON.parse(output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get flows')
        data = []
      end

      data.each do |d|
        if d['builtIn']
          Puppet.debug("Skipping builtIn flow #{d['alias']}")
          next
        end
        flow = {}
        flow[:ensure] = :present
        flow[:top_level] = :true
        flow[:id] = d['id']
        flow[:alias] = d['alias']
        flow[:realm] = realm
        flow[:description] = d['description']
        flow[:provider_id] = d['providerId']
        flow[:name] = "#{flow[:alias]} on #{flow[:realm]}"
        flows << new(flow)
        begin
          executions_output = kcadm('get', "authentication/flows/#{d['alias']}/executions", realm)
        rescue StandardError
          Puppet.notice("Unable to query flow #{d['alias']} executions")
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
          unless e['authenticationFlow']
            Puppet.debug("Skipping non-authentication flow #{e['displayName']} for keycloak_flow")
            next
          end
          flow = {}
          flow[:ensure] = :present
          flow[:top_level] = :false
          flow[:id] = e['id']
          flow[:requirement] = e['requirement']
          flow[:configurable] = e['configurable'] if e.key?('configurable')
          flow[:flow_alias] = d['alias']
          flow[:realm] = realm
          flow[:description] = e['description']
          flow[:priority] = e['priority']
          flow[:display_name] = e['displayName']
          flow[:alias] = e['displayName']
          if e['level'] != 0
            parent_level = levels.find { |k, _v| k == (e['level'] - 1) }
            flow[:flow_alias] = parent_level[1][-1] if parent_level.size > 1
          end
          flow[:name] = "#{flow[:alias]} under #{flow[:flow_alias]} on #{realm}"
          levels[e['level']] = [] unless levels.key?(e['level'])
          levels[e['level']] << flow[:alias]
          flows << new(flow)
        end
      end
    end
    flows
  end

  def self.prefetch(resources)
    flows = instances
    resources.each_key do |name|
      provider = flows.find do |c|
        (c.alias == resources[name][:alias] && c.flow_alias == resources[name][:flow_alias] && c.realm == resources[name][:realm]) ||
          (c.alias == resources[name][:alias] && c.realm == resources[name][:realm])
      end
      if provider
        resources[name].provider = provider
      end
    end
  end

  def create
    data = {}
    data[:alias] = resource[:alias]
    if resource[:top_level] == :true
      data[:id] = resource[:id]
      data[:description] = resource[:description]
      data[:providerId] = resource[:provider_id]
      data[:topLevel] = true
      url = 'authentication/flows'
    else
      data[:provider] = resource[:type]
      data[:description] = resource[:description]
      data[:type] = resource[:provider_id]
      data[:priority] = resource[:priority]
      url = "authentication/flows/#{resource[:flow_alias]}/executions/flow"
    end
    t = Tempfile.new('keycloak_flow')
    t.write(JSON.pretty_generate(data))
    t.close
    Puppet.debug(IO.read(t.path))
    begin
      new_id = kcadm('create', url, resource[:realm], t.path, nil, true)
      Puppet.debug("create flow output: #{new_id}")
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "kcadm create flow failed\nError message: #{e.message}"
    end
    if resource[:top_level] == :false && resource[:requirement]
      execution_output = kcadm('get', "authentication/flows/#{resource[:flow_alias]}/executions", resource[:realm])
      begin
        execution_data = JSON.parse(execution_output)
      rescue JSON::ParserError
        Puppet.debug('Unable to parse output from kcadm get flow executions')
        execution_data = []
      end
      execution_id = nil
      execution_data.each do |ed|
        next unless ed['flowId'] == new_id.strip

        execution_id = ed['id']
      end
      unless execution_id.nil?
        update_data = {
          id: execution_id,
          requirement: resource[:requirement],
          priority: resource[:priority]
        }
        t = Tempfile.new('keycloak_flow_execution')
        t.write(JSON.pretty_generate(update_data))
        t.close
        Puppet.debug(IO.read(t.path))
        begin
          output = kcadm('update', "authentication/flows/#{resource[:flow_alias]}/executions", resource[:realm], t.path, nil, true)
          Puppet.debug("update flow execution output: #{output}")
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update flow execution failed\nError message: #{e.message}"
        end
      end
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    url = if resource[:top_level] == :true
            "authentication/flows/#{id}"
          else
            "authentication/executions/#{id}"
          end
    begin
      kcadm('delete', url, resource[:realm])
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
      data = {}
      if resource[:top_level] == :true
        data[:id] = resource[:id]
        data[:alias] = resource[:alias]
        data[:description] = resource[:description]
        data[:providerId] = resource[:provider_id]
        data[:topLevel] = true
        url = "authentication/flows/#{id}"
      elsif @property_flush[:requirement] || @property_flush[:priority]
        data[:id] = id
        data[:description] = resource[:description]
        data[:requirement] = resource[:requirement]
        data[:priority] = resource[:priority]
        url = "authentication/flows/#{resource[:flow_alias]}/executions"
      end
      unless data.empty?
        t = Tempfile.new('keycloak_flow')
        t.write(JSON.pretty_generate(data))
        t.close
        Puppet.debug(IO.read(t.path))
        begin
          kcadm('update', url, resource[:realm], t.path, nil, true)
        rescue Puppet::ExecutionFailure => e
          raise Puppet::Error, "kcadm update flow failed\nError message: #{e.message}"
        end
      end
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = resource.to_hash
  end
end
