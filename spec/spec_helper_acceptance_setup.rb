RSpec.configure do |c|
  c.add_setting :keycloak_version
  keycloak_version = if ENV['BEAKER_keycloak_version'].nil? || ENV['BEAKER_keycloak_version'].empty?
                       '18.0.0'
                     else
                       ENV['BEAKER_keycloak_version']
                     end
  c.keycloak_version = keycloak_version
  c.add_setting :keycloak_full
  c.keycloak_full = (ENV['BEAKER_keycloak_full'] == 'true' || ENV['BEAKER_keycloak_full'] == 'yes')
end

proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
scp_to(hosts, File.join(proj_root, 'spec/fixtures/keycloak-duo-spi-jar-with-dependencies.jar'), '/tmp/keycloak-duo-spi-jar-with-dependencies.jar')

hiera_yaml = <<-EOS
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
EOS
centos7_yaml = <<-EOS
postgresql::server::service_reload: 'systemctl reload postgresql 2>/dev/null 1>/dev/null'
EOS
ubuntu1804_yaml = <<-EOS
keycloak::db: mysql
EOS
# TODO: Use until this released to force mariadb:
# https://github.com/puppetlabs/puppetlabs-mysql/commit/8c8c01739f593b2bcd1943297761a09dde994197
ubuntu2004_yaml = <<-EOS
keycloak::db: mysql
EOS
common_yaml = <<-EOS
---
keycloak::version: '#{RSpec.configuration.keycloak_version}'
keycloak::http_host: '127.0.0.1'
keycloak::db: mariadb
keycloak::proxy: edge
postgresql::server::service_status: 'service postgresql status 2>/dev/null 1>/dev/null'
EOS

create_remote_file(hosts, '/etc/puppetlabs/puppet/hiera.yaml', hiera_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/common.yaml', common_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data/os/CentOS'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/os/CentOS/7.yaml', centos7_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data/os/Ubuntu'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/os/Ubuntu/18.04.yaml', ubuntu1804_yaml)
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/os/Ubuntu/20.04.yaml', ubuntu2004_yaml)
