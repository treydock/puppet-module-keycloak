# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

dir = __dir__
Dir["#{dir}/acceptance/shared_examples/**/*.rb"].sort.each { |f| require f }
require 'spec_helper_acceptance_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_acceptance_local.rb'))

if ['debian-12', 'debian-13', 'ubuntu-2404', 'ubuntu-2604'].include?(ENV['BEAKER_set'])
  ENV['BEAKER_PUPPET_COLLECTION'] = 'none'
end
configure_beaker

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end

require 'spec_helper_acceptance_setup' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_acceptance_setup.rb'))
# 'spec_overrides' from sync.yml will appear below this line
