require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

dir = File.expand_path(File.dirname(__FILE__))
Dir["#{dir}/acceptance/shared_examples/**/*.rb"].sort.each {|f| require f}

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  c.before :suite do
    hosts.each do |h|
      install_puppet_module_via_pmt_on(h, :module_name => 'puppetlabs-inifile')
      puppet_pp = <<-EOF
      ini_setting { 'puppet.conf/main/show_diff':
        ensure  => 'present',
        section => 'main',
        path    => '/etc/puppet/puppet.conf',
        setting => 'show_diff',
        value   => 'true',
      }
      ini_setting { 'puppet.conf/main/parser':
        ensure  => 'present',
        section => 'main',
        path    => '/etc/puppet/puppet.conf',
        setting => 'parser',
        value   => 'future',
      }
      EOF
      apply_manifest_on(h, puppet_pp, :catch_failures => true)
    end
  end
end
