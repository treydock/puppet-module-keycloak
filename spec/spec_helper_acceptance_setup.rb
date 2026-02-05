# frozen_string_literal: true

RSpec.configure do |c|
  c.add_setting :keycloak_version
  keycloak_version = if ENV['BEAKER_keycloak_version'].nil? || ENV['BEAKER_keycloak_version'].empty?
                       '25.0.1'
                     else
                       ENV['BEAKER_keycloak_version']
                     end
  c.keycloak_version = keycloak_version
  c.add_setting :keycloak_full
  c.add_setting :keycloak_full_batch1
  c.add_setting :keycloak_full_batch2
  c.keycloak_full_batch1 = ENV['BEAKER_keycloak_full'] == 'batch1'
  c.keycloak_full_batch2 = ENV['BEAKER_keycloak_full'] == 'batch2'
  c.keycloak_full = (c.keycloak_full_batch1 || c.keycloak_full_batch2)
end

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
scp_to(hosts, File.join(proj_root, 'spec/fixtures/DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar'), '/tmp/DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar')
scp_to(hosts, File.join(proj_root, 'spec/fixtures/partial-import.json'), '/tmp/partial-import.json')

hiera_yaml = <<-HIERA_YAML
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data
hierarchy:
  - name: 'os family major release'
    path: "os/%{facts.os.name}/%{facts.os.release.major}.yaml"
  - name: "Common"
    path: "common.yaml"
HIERA_YAML
common_yaml = <<-COMMON_YAML
---
keycloak::version: '#{RSpec.configuration.keycloak_version}'
keycloak::http_host: '0.0.0.0'
keycloak::hostname: localhost
keycloak::db: mariadb
keycloak::proxy: edge
keycloak::features:
  - scripts
# Force only listen on IPv4 for testing
keycloak::java_opts: '-Djava.net.preferIPv4Stack=true'
postgresql::server::service_status: 'service postgresql status 2>/dev/null 1>/dev/null'
COMMON_YAML

create_remote_file(hosts, '/etc/puppetlabs/puppet/hiera.yaml', hiera_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/common.yaml', common_yaml)
