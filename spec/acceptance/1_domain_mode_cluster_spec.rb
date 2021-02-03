require 'spec_helper_acceptance'

describe 'keycloak domain mode cluster', if: RSpec.configuration.keycloak_domain_mode_cluster do
  node = hosts_as('keycloak-master-el7')
  context 'default with domain master' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak':
        operating_mode        => 'domain',
        role                  => 'master',
        datasource_driver     => 'postgresql',
        wildfly_user          => 'wildfly',
        wildfly_user_password => 'wildfly',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('keycloak') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
