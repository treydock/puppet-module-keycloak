RSpec.configure do |c|
  c.add_setting :keycloak_version
  keycloak_version = if ENV['BEAKER_keycloak_version'].nil? || ENV['BEAKER_keycloak_version'].empty?
                       '8.0.1'
                     else
                       ENV['BEAKER_keycloak_version']
                     end
  c.keycloak_version = keycloak_version
  c.add_setting :keycloak_full
  c.keycloak_full = (ENV['BEAKER_keycloak_full'] == 'true' || ENV['BEAKER_keycloak_full'] == 'yes')
  c.add_setting :keycloak_domain_mode_cluster
  c.keycloak_domain_mode_cluster = (ENV['BEAKER_keycloak_domain_mode_cluster'] == 'true' || ENV['BEAKER_keycloak_domain_mode_cluster'] == 'yes')
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
    path: "os/%{facts.os.family}/%{facts.os.release.major}.yaml"
  - name: "Common"
    path: "common.yaml"
EOS
# Hack until released: https://github.com/puppetlabs/puppetlabs-mysql/pull/1264
debian10_yaml = <<-EOS
mysql::bindings::java_package_name: libmariadb-java
EOS
common_yaml = <<-EOS
---
keycloak::version: '#{RSpec.configuration.keycloak_version}'
postgresql::globals::service_status: 'service postgresql status'
EOS

create_remote_file(hosts, '/etc/puppetlabs/puppet/hiera.yaml', hiera_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/common.yaml', common_yaml)
on hosts, 'mkdir -p /etc/puppetlabs/puppet/data/os/Debian'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/os/Debian/10.yaml', debian10_yaml)
