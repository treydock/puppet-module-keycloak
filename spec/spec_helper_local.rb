# frozen_string_literal: true

include RspecPuppetFacts # rubocop:disable Style/MixinUsage
add_custom_fact :concat_basedir, '/dne'
add_custom_fact :service_provider, 'systemd'
add_custom_fact :staging_http_get, '/usr/bin/wget'

def verify_exact_file_contents(subject, title, expected_lines)
  content = subject.resource('file', title).send(:parameters)[:content]
  expect(content.split("\n").reject { |line| line =~ %r{(^$|^#)} }).to match_array expected_lines
end
