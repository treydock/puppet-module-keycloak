#!/opt/puppetlabs/puppet/bin/ruby
#
# Simple script to enable testing the functionality of keycloak_role_mapping provider.
# Not expected to be useful outside of the Beaker tests, nor to be robust against
# unexpected situations.
#
require 'json'

if ARGV[0] == 'groups'
  path = 'groups'
  filter = 'name=testgroup'
elsif ARGV[0] == 'users'
  path = 'users'
  filter = 'username=admin'
else
  puts 'ERROR: must pass "users" or "groups" as parameter'
  exit 1
end

# Get the ID of the user or group
uid = JSON.parse(`/opt/keycloak/bin/kcadm-wrapper.sh get #{path}?#{filter} -r master`)[0]['id']

# Get role realm role mappings using the ID
realm_role_mappings = []
JSON.parse(`/opt/keycloak/bin/kcadm-wrapper.sh get #{path}/#{uid}/role-mappings -r master`)['realmMappings'].each do |mapping|
  realm_role_mappings << mapping['name']
end

p realm_role_mappings
