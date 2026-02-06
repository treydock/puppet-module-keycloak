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

puppet_dir = if fact('os.name') == 'Debian' && fact('os.release.major').to_i >= 12
               '/etc/puppet'
             else
               '/etc/puppetlabs/puppet'
             end
default_db = if fact('os.family') == 'RedHat' && fact('os.release.major').to_i >= 10
               'postgres'
             else
               'mariadb'
             end
hiera_yaml = <<-HIERA_YAML
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data
hierarchy:
  - name: 'os family major release'
    path: "os/%{facts.os.family}/%{facts.os.release.major}.yaml"
  - name: "Common"
    path: "common.yaml"
HIERA_YAML
common_yaml = <<-COMMON_YAML
---
keycloak::version: '#{RSpec.configuration.keycloak_version}'
keycloak::http_host: '0.0.0.0'
keycloak::hostname: localhost
keycloak::db: #{default_db}
keycloak::proxy: edge
keycloak::features:
  - scripts
# Force only listen on IPv4 for testing
keycloak::java_opts: '-Djava.net.preferIPv4Stack=true'
COMMON_YAML

# Remove logic once merged and released:
# https://github.com/puppetlabs/puppetlabs-postgresql/pull/1650
el10_yaml = <<-EL10_YAML
---
postgresql::globals::version: '16'
postgresql::globals::manage_package_repo: true
EL10_YAML

create_remote_file(hosts, File.join(puppet_dir, 'hiera.yaml'), hiera_yaml)
on hosts, "mkdir -p #{File.join(puppet_dir, 'data')}"
create_remote_file(hosts, File.join(puppet_dir, 'data/common.yaml'), common_yaml)
on hosts, "mkdir -p #{File.join(puppet_dir, 'data/os/RedHat')}"
create_remote_file(hosts, File.join(puppet_dir, 'data/os/RedHat/10.yaml'), el10_yaml)
