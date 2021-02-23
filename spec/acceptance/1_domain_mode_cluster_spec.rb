require 'spec_helper_acceptance'

# This check needs to be here or Beaker will try to run find_only_one on
# non-domain-mode tests and fail miserably.
describe 'keycloak domain mode cluster' if RSpec.configuration.keycloak_domain_mode_cluster

domain_master = find_only_one('domain_master')
domain_slave = find_only_one('domain_slave')
db = find_only_one('db')

context 'new cluster' do
  it 'launches' do
    db_pp = <<-EOS
    class { '::postgresql::globals':
      manage_package_repo => true,
      version             => '9.6',
    }

    class { '::postgresql::server':
      listen_addresses => '*',
      require          => Class['::postgresql::globals']
    }

    ::postgresql::server::role { 'keycloak':
      password_hash    => postgresql_password('keycloak', 'keycloak'),
      connection_limit => 300,
      require          => Class['::postgresql::server']
    }

    ::postgresql::server::database_grant { 'Grant all to keycloak':
      privilege => 'ALL',
      db        => 'keycloak',
      role      => 'keycloak',
    }

    ::postgresql::server::db { 'keycloak':
      user     => 'keycloak',
      password => postgresql_password('keycloak', 'keycloak'),
    }
    
    postgresql::server::pg_hba_rule { 'Allow Keycloak instances network access to the database':
      description => 'Open up PostgreSQL for access from anywhere',
      type        => 'host',
      database    => 'keycloak',
      user        => 'keycloak',
      address     => '0.0.0.0/0',
      auth_method => 'md5',
      require     => Class['::postgresql::server']
    }
    EOS

    master_pp = <<-EOS
    class { '::keycloak':
      operating_mode          => 'domain',
      role                    => 'master',
      management_bind_address => $::ipaddress,
      enable_jdbc_ping        => true,
      wildfly_user            => 'wildfly',
      wildfly_user_password   => 'wildfly',
      manage_install          => true,
      manage_datasource       => false,
      version                 => '10.0.1',
      datasource_driver       => 'postgresql',
      datasource_host         => 'centos-7-db',
      datasource_port         => 5432,
      datasource_dbname       => 'keycloak',
      datasource_username     => 'keycloak',
      datasource_password     => 'keycloak',
      admin_user              => 'admin',
      admin_user_password     => 'changeme',
      service_bind_address    => '0.0.0.0',
      proxy_https             => false,
    }
    EOS

    slave_pp = <<-EOS
    class { '::keycloak':
      operating_mode          => 'domain',
      role                    => 'slave',
      enable_jdbc_ping        => true,
      management_bind_address => $::ipaddress,
      wildfly_user            => 'wildfly',
      wildfly_user_password   => 'wildfly',
      master_address          => 'centos-7-master',
      manage_install          => true,
      manage_datasource       => false,
      version                 => '10.0.1',
      datasource_driver       => 'postgresql',
      datasource_host         => 'centos-7-db',
      datasource_port         => 5432,
      datasource_dbname       => 'keycloak',
      datasource_username     => 'keycloak',
      datasource_password     => 'keycloak',
      admin_user              => 'admin',
      admin_user_password     => 'changeme',
      service_bind_address    => '0.0.0.0',
      proxy_https             => false,
    }
    EOS

    apply_manifest_on(db, db_pp, catch_failures: true)
    apply_manifest_on(domain_master, master_pp, catch_failures: true)
    apply_manifest_on(domain_master, master_pp, catch_changes: true)
    apply_manifest_on(domain_slave,  slave_pp,  catch_failures: true)
    apply_manifest_on(domain_slave,  slave_pp,  catch_changes: true)
  end

  describe service('keycloak'), node: domain_master do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe service('keycloak'), node: domain_slave do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  it 'data replicates from master to slave' do
    on domain_master, '/opt/keycloak/bin/kcadm-wrapper.sh create roles -r master -s name=testrole'
    on domain_slave, '/opt/keycloak/bin/kcadm-wrapper.sh get roles/testrole -r master' do
      data = JSON.parse(stdout)
      expect(data['name']).to eq('testrole')
    end
  end

  it 'data replicates from slave to master' do
    on domain_slave, '/opt/keycloak/bin/kcadm-wrapper.sh delete roles/testrole -r master'
    on domain_master, '/opt/keycloak/bin/kcadm-wrapper.sh get roles -r master' do
      data = JSON.parse(stdout)
      match = data.select { |role| role['name'] == 'testrole' }
      expect(match).to be_empty
    end
  end
end


