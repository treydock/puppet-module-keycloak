require 'spec_helper_acceptance'

describe 'keycloak domain mode cluster', if: RSpec.configuration.keycloak_domain_mode_cluster do
  domain_master = find_only_one('domain_master')
  domain_slave = find_only_one('domain_slave')
  p domain_master.class
  p domain_slave.class

  context 'domain test' do
    it 'replication is successful' do
      master_pp = <<-EOS
      file { '/tmp/master':
        ensure => 'present',
      }
      EOS

      #master_pp = <<-EOS
      #class { 'keycloak':
      #  operating_mode        => 'domain',
      #  role                  => 'master',
      #  datasource_driver     => 'postgresql',
      #  wildfly_user          => 'wildfly',
      #  wildfly_user_password => 'wildfly',
      #}

      slave_pp = <<-EOS
      file { '/tmp/slave':
        ensure => 'present',
      }
      EOS

      on domain_master, 'echo foo > /tmp/echo-master'
      on domain_slave, 'echo foo > /tmp/echo-slave'

      apply_manifest_on(domain_master, master_pp, catch_changes: true)
      apply_manifest_on(domain_master, master_pp, catch_failures: true)
      apply_manifest_on(domain_slave,  slave_pp,  catch_failures: true)
    end
  end
end
