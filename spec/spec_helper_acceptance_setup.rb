# frozen_string_literal: true

RSpec.configure do |c|
  c.add_setting :keycloak_version
  keycloak_version = if ENV['BEAKER_keycloak_version'].nil? || ENV['BEAKER_keycloak_version'].empty?
                       '19.0.3'
                     else
                       ENV['BEAKER_keycloak_version']
                     end
  c.keycloak_version = keycloak_version
  c.add_setting :keycloak_full
  c.keycloak_full = (ENV['BEAKER_keycloak_full'] == 'true' || ENV['BEAKER_keycloak_full'] == 'yes')
end

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
scp_to(hosts, File.join(proj_root, 'spec/fixtures/DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar'), '/tmp/DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar')
scp_to(hosts, File.join(proj_root, 'spec/fixtures/mappers.jar'), '/tmp/mappers.jar')

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
centos7_yaml = <<-EL7_YAML
postgresql::server::service_reload: 'systemctl reload postgresql 2>/dev/null 1>/dev/null'
EL7_YAML
ubuntu1804_yaml = <<-UBUNTU18_YAML
keycloak::db: mysql
UBUNTU18_YAML
common_yaml = <<-COMMON_YAML
---
keycloak::version: '#{RSpec.configuration.keycloak_version}'
keycloak::http_host: '127.0.0.1'
keycloak::db: mariadb
keycloak::proxy: edge
postgresql::server::service_status: 'service postgresql status 2>/dev/null 1>/dev/null'
COMMON_YAML

create_remote_file(hosts, '/etc/puppetlabs/puppet/hiera.yaml', hiera_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/common.yaml', common_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data/os/CentOS'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/os/CentOS/7.yaml', centos7_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data/os/Ubuntu'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/os/Ubuntu/18.04.yaml', ubuntu1804_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data/os/Debian'
