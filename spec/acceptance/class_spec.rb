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

    describe file('/opt/keycloak-2.5.4.Final') do
      it { should be_directory }
    end

    describe service('keycloak') do
      it { should be_enabled }
      it { should be_running }
    end

#    describe file('/etc/keycloak.conf') do
#      it { should be_file }
#      it { should be_mode 644 }
#      it { should be_owned_by 'root' }
#      it { should be_grouped_into 'root' }
#    end
  end

  context 'non-default parameters' do
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
  end
end
