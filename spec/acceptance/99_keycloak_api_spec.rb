require 'spec_helper_acceptance'

describe 'keycloak_api:' do
  context 'creates realm' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
        version => '4.0.0.Beta3',
      }
      keycloak_api { 'keycloak':
        install_base => '/opt/keycloak',
      }
      keycloak_realm { 'test2': ensure => 'present' }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  context 'updates realm' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
        version => '4.0.0.Beta3',
      }
      keycloak_api { 'keycloak':
        install_base => '/opt/keycloak',
      }
      keycloak_realm { 'test2':
        ensure => 'present',
        remember_me => true,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
