require 'beaker-rspec'
require 'beaker-puppet'
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
end
