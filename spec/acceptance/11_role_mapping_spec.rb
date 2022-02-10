require 'spec_helper_acceptance'

describe 'keycloak_role_mapping:', if: RSpec.configuration.keycloak_full do
  context 'removes role mappings for admin' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_role_mapping { 'admin':
        realm       => 'master',
	name        => 'admin',
	group       => false,
	realm_roles => ['admin'],
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has removed role mappings for admin' do
      scp_to hosts, 'spec/acceptance/get_role_mappings.rb', '/tmp'

      on hosts, '/tmp/get_role_mappings.rb users' do
        data = JSON.parse(stdout)
        expect(data.sort).to eq(['admin'])
      end
    end
  end

  context 'adds role mappings for admin' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_role_mapping { 'admin':
        realm       => 'master',
	name        => 'admin',
	group       => false,
	realm_roles => ['admin', 'offline_access'],
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has added role mappings for admin' do
      scp_to hosts, 'spec/acceptance/get_role_mappings.rb', '/tmp'

      on hosts, '/tmp/get_role_mappings.rb users' do
        data = JSON.parse(stdout)
        expect(data.sort).to eq(['admin', 'offline_access'])
      end
    end
  end

  context 'adds role mappings for testgroup' do
    it 'has added testgroup' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh create groups -r master -s name=testgroup'
    end

    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_role_mapping { 'testgroup':
        realm       => 'master',
	name        => 'testgroup',
	group       => true,
	realm_roles => ['admin'],
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has added role mappings for testgroup' do
      scp_to hosts, 'spec/acceptance/get_role_mappings.rb', '/tmp'

      on hosts, '/tmp/get_role_mappings.rb groups' do
        data = JSON.parse(stdout)
        expect(data.sort).to eq(['admin'])
      end
    end
  end
end
