require 'spec_helper_acceptance'

describe 'keycloak class:' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
      class { 'keycloak': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/opt/keycloak-3.0.0.Final') do
      it { should be_directory }
    end

    describe service('keycloak') do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'default with mysql datasource' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe service('keycloak') do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(8080) do
      it { should be_listening.on('0.0.0.0').with('tcp') }
    end

    describe port(9990) do
      it { should be_listening.on('127.0.0.1').with('tcp') }
    end
  end

  context 'change admin password' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
        admin_user_password => 'foobar',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe command('/opt/keycloak/bin/kcadm-wrapper.sh get users') do
      its(:exit_status) { should eq 0 }
    end
  end

  context 'change admin password back to default' do
    it 'should run successfully' do
      pp =<<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe command('/opt/keycloak/bin/kcadm-wrapper.sh get users') do
      its(:exit_status) { should eq 0 }
    end
  end
end
