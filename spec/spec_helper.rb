require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter '/spec/'
  end
rescue Exception => e
  warn "Coveralls disabled"
end

dir = File.expand_path(File.dirname(__FILE__))
Dir["#{dir}/shared_examples/**/*.rb"].sort.each {|f| require f}

at_exit { RSpec::Puppet::Coverage.report! }

RSpec.configure do |config|
  config.mock_with :rspec
end

add_custom_fact :concat_basedir, '/dne'
add_custom_fact :service_provider, 'systemd', :confine => 'redhat-7-x86_64'
add_custom_fact :staging_http_get, '/usr/bin/wget'
