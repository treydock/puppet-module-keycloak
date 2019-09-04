require 'spec_helper_acceptance'

describe 'keycloak_ldap_user_provider:', if: RSpec.configuration.keycloak_full do
  context 'creates ldap' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'LDAP':
        realm => 'test',
        users_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
        custom_user_search_filter => '(objectClass=posixAccount)',
      }
      keycloak_ldap_mapper { 'full-name':
        realm => 'test',
        ldap  => 'LDAP-test',
        type => 'full-name-ldap-mapper',
        ldap_attribute => 'foo',
      }
      keycloak_ldap_mapper { "first name for LDAP-test on test":
        ensure               => 'present',
        type                 => 'user-attribute-ldap-mapper',
        user_model_attribute => 'firstName',
        ldap_attribute       => 'givenName',
      }
      keycloak_ldap_mapper { 'group-role for LDAP-test on test':
        type              => 'role-ldap-mapper',
        roles_dn          => 'ou=Groups,dc=example,dc=com',
        roles_ldap_filter => '(!(cn=P*))',
      }
      keycloak_ldap_mapper { 'group for LDAP-test on test':
        type               => 'group-ldap-mapper',
        groups_dn          => 'ou=Groups,dc=example,dc=com',
        groups_ldap_filter => '(cn=P*)',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components/LDAP-test -r test' do
        data = JSON.parse(stdout)
        expect(data['config']['usersDn']).to eq(['ou=People,dc=test'])
        expect(data['config']['connectionUrl']).to eq(['ldap://localhost:389'])
        expect(data['config']['customUserSearchFilter']).to eq(['(objectClass=posixAccount)'])
      end
    end

    it 'has created a LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'full-name' }[0]
        expect(d['providerId']).to eq('full-name-ldap-mapper')
        expect(d['config']['ldap.full.name.attribute']).to eq(['foo'])
      end
    end

    it 'has set firstName LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'first name' }[0]
        expect(d['providerId']).to eq('user-attribute-ldap-mapper')
        expect(d['config']['user.model.attribute']).to eq(['firstName'])
        expect(d['config']['ldap.attribute']).to eq(['givenName'])
      end
    end

    it 'has set group-role LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'group-role' }[0]
        expect(d['providerId']).to eq('role-ldap-mapper')
        expect(d['config']['roles.dn']).to eq(['ou=Groups,dc=example,dc=com'])
        expect(d['config']['roles.ldap.filter']).to eq(['(!(cn=P*))'])
      end
    end

    it 'has set group LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'group' }[0]
        expect(d['providerId']).to eq('group-ldap-mapper')
        expect(d['config']['groups.dn']).to eq(['ou=Groups,dc=example,dc=com'])
        expect(d['config']['groups.ldap.filter']).to eq(['(cn=P*)'])
      end
    end
  end

  context 'updates ldap' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'LDAP':
        realm => 'test',
        users_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
        user_object_classes => ['posixAccount'],
      }
      keycloak_ldap_mapper { 'full-name':
        realm => 'test',
        ldap  => 'LDAP-test',
        type => 'full-name-ldap-mapper',
        ldap_attribute => 'bar',
      }
      keycloak_ldap_mapper { 'group-role for LDAP-test on test':
        type              => 'role-ldap-mapper',
        roles_dn          => 'ou=Groups,dc=example,dc=com',
        roles_ldap_filter => '(!(cn=P0*))',
      }
      keycloak_ldap_mapper { 'group for LDAP-test on test':
        type               => 'group-ldap-mapper',
        groups_dn          => 'ou=Groups,dc=example,dc=com',
        groups_ldap_filter => '(cn=P0*)',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components/LDAP-test -r test' do
        data = JSON.parse(stdout)
        expect(data['config']['usersDn']).to eq(['ou=People,dc=test'])
        expect(data['config']['connectionUrl']).to eq(['ldap://localhost:389'])
        expect(data['config']['userObjectClasses']).to eq(['posixAccount'])
        expect(data['config'].key?('customUserSearchFilter')).to eq(false)
      end
    end

    it 'has updated a LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'full-name' }[0]
        expect(d['providerId']).to eq('full-name-ldap-mapper')
        expect(d['config']['ldap.full.name.attribute']).to eq(['bar'])
      end
    end

    it 'has updated group-role LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'group-role' }[0]
        expect(d['providerId']).to eq('role-ldap-mapper')
        expect(d['config']['roles.dn']).to eq(['ou=Groups,dc=example,dc=com'])
        expect(d['config']['roles.ldap.filter']).to eq(['(!(cn=P0*))'])
      end
    end

    it 'has updated group LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'group' }[0]
        expect(d['providerId']).to eq('group-ldap-mapper')
        expect(d['config']['groups.dn']).to eq(['ou=Groups,dc=example,dc=com'])
        expect(d['config']['groups.ldap.filter']).to eq(['(cn=P0*)'])
      end
    end
  end

  context 'creates ldap with simple auth' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'LDAP2':
        realm => 'test',
        users_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
        custom_user_search_filter => '(objectClass=posixAccount)',
        auth_type => 'simple',
        bind_dn => 'cn=read,ou=People,dc=test',
        bind_credential => 'test',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components/LDAP2-test -r test' do
        data = JSON.parse(stdout)
        expect(data['config']['authType']).to eq(['simple'])
        expect(data['config']['bindDn']).to eq(['cn=read,ou=People,dc=test'])
        expect(data['config']['bindCredential'][0]).to match(%r{^[\*]+$})
      end
    end

    it 'has set bindCredential' do
      on hosts, "mysql keycloak -BN -e 'SELECT VALUE FROM COMPONENT_CONFIG WHERE NAME=\"bindCredential\" AND COMPONENT_ID=\"LDAP2-test\"'" do
        expect(stdout).to match(%r{^test$})
      end
    end
  end

  context 'updates ldap auth' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'LDAP':
        realm => 'test',
        users_dn => 'ou=People,dc=test',
        connection_url => 'ldap://localhost:389',
        user_object_classes => ['posixAccount'],
        auth_type => 'simple',
        bind_dn => 'cn=read,ou=People,dc=test',
        bind_credential => 'test',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components/LDAP-test -r test' do
        data = JSON.parse(stdout)
        expect(data['config']['authType']).to eq(['simple'])
        expect(data['config']['bindDn']).to eq(['cn=read,ou=People,dc=test'])
        expect(data['config']['bindCredential'][0]).to match(%r{^[\*]+$})
      end
    end

    it 'has set bindCredential' do
      on hosts, "mysql keycloak -BN -e 'SELECT VALUE FROM COMPONENT_CONFIG WHERE NAME=\"bindCredential\" AND COMPONENT_ID=\"LDAP-test\"'" do
        expect(stdout).to match(%r{^test$})
      end
    end
  end

  context 'ensure => absent' do
    it 'runs successfully' do
      pp = <<-EOS
      include mysql::server
      class { 'keycloak':
        datasource_driver => 'mysql',
      }
      keycloak_ldap_mapper { 'full-name':
        ensure => 'absent',
        realm  => 'test',
        ldap   => 'LDAP-test',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has deleted ldap mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'full-name' }[0]
        expect(d).to be_nil
      end
    end
  end
end
