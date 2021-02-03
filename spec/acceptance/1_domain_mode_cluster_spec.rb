require 'spec_helper_acceptance'

describe 'keycloak domain mode cluster', if: RSpec.configuration.keycloak_domain_mode_cluster do
  domain_master = find_only_one('domain_master')
  domain_slave = find_only_one('domain_slave')

  context 'domain test' do
    it 'replication is successful' do
      master_pp = <<-EOS
      class { 'keycloak':
        operating_mode        => 'domain',
        role                  => 'master',
        datasource_driver     => 'postgresql',
        wildfly_user          => 'wildfly',
        wildfly_user_password => 'wildfly',
      }
      EOS

      slave_pp = <<-EOS
      class { 'keycloak':
        operating_mode        => 'domain',
        role                  => 'slave',
	    master_address        => 'centos-7-master',
        datasource_driver     => 'postgresql',
        wildfly_user          => 'wildfly',
        wildfly_user_password => 'wildfly',
      }
      EOS

      apply_manifest_on(domain_master, master_pp, catch_failures: true)
      apply_manifest_on(domain_master, master_pp, catch_changes: true)
      apply_manifest_on(domain_slave,  slave_pp,  catch_failures: true)
    end
  end
end
