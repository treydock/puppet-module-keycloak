RSpec.configure do |c|
  c.add_setting :keycloak_version
  c.keycloak_version = (ENV['BEAKER_keycloak_version'] || '4.2.1.Final')
end

hiera_yaml = <<-EOS
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data
hierarchy:
  - name: "Common"
    path: "common.yaml"
EOS
common_yaml = <<-EOS
---
keycloak::version: '#{RSpec.configuration.keycloak_version}'
EOS

create_remote_file(hosts, '/etc/puppetlabs/puppet/hiera.yaml', hiera_yaml)
on hosts, 'mkdir /etc/puppetlabs/puppet/data'
create_remote_file(hosts, '/etc/puppetlabs/puppet/data/common.yaml', common_yaml)
