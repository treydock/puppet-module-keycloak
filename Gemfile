source "http://rubygems.org"

group :development, :test do
  if RUBY_VERSION.start_with? '1.8'
    gem 'rake', '< 11',           :require => false
  else
    gem 'rake', '< 12',           :require => false
  end
  gem 'rspec', '~>3.1.0',         :require => false
  gem 'rspec-puppet', '~>2.x',    :require => false
  gem 'rspec-puppet-facts',       :require => false
  gem 'puppetlabs_spec_helper',   :require => false
  gem 'puppet-lint',              :require => false
  gem 'metadata-json-lint',       :require => false
  gem 'puppet-syntax',            :require => false
  gem 'simplecov',                :require => false
  gem 'json_pure', '~>1.x',       :require => false
end

group :system_tests do
  gem 'beaker',                       :require => false
  gem 'beaker-rspec',                 :require => false
  gem 'serverspec',                   :require => false
  gem 'beaker-puppet_install_helper', :require => false
  gem 'beaker-module_install_helper', :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

gem 'puppet', ENV['PUPPET_GEM_VERSION'] || '~> 5.x', :require => false
