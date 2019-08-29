require 'spec_helper_acceptance'

describe 'keycloak_ldap_user_provider:', if: RSpec.configuration.keycloak_full do
  context 'creates ldap' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'LDAP':
        realm                     => 'test',
        users_dn                  => 'ou=People,dc=test',
        connection_url            => 'ldap://localhost:389',
        custom_user_search_filter => '(objectClass=posixAccount)',
      }
      keycloak_ldap_mapper { 'full-name':
        realm          => 'test',
        ldap           => 'LDAP',
        type           => 'full-name-ldap-mapper',
        ldap_attribute => 'foo',
      }
      keycloak_ldap_mapper { "first name for LDAP on test":
        ensure               => 'present',
        type                 => 'user-attribute-ldap-mapper',
        user_model_attribute => 'firstName',
        ldap_attribute       => 'givenName',
      }
      keycloak_ldap_mapper { 'group-role for LDAP on test':
        type              => 'role-ldap-mapper',
        roles_dn          => 'ou=Groups,dc=example,dc=com',
        roles_ldap_filter => '(!(cn=P*))',
      }
      keycloak_ldap_mapper { 'group for LDAP on test':
        type               => 'group-ldap-mapper',
        groups_dn          => 'ou=Groups,dc=example,dc=com',
        groups_ldap_filter => '(cn=P*)',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'LDAP' }[0]
        expect(d['config']['usersDn']).to eq(['ou=People,dc=test'])
        expect(d['config']['connectionUrl']).to eq(['ldap://localhost:389'])
        expect(d['config']['customUserSearchFilter']).to eq(['(objectClass=posixAccount)'])
        expect(d['config']['trustEmail']).to eq(['false'])
        expect(d['config']['fullSyncPeriod']).to eq(['-1'])
        expect(d['config']['changedSyncPeriod']).to eq(['-1'])
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
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'LDAP':
        realm               => 'test',
        users_dn            => 'ou=People,dc=test',
        connection_url      => 'ldap://localhost:389',
        user_object_classes => ['posixAccount'],
        trust_email         => true,
        full_sync_period    => 60,
        changed_sync_period => 30,
      }
      keycloak_ldap_mapper { 'full-name':
        realm          => 'test',
        ldap           => 'LDAP',
        type           => 'full-name-ldap-mapper',
        ldap_attribute => 'bar',
      }
      keycloak_ldap_mapper { 'group-role for LDAP on test':
        type              => 'role-ldap-mapper',
        roles_dn          => 'ou=Groups,dc=example,dc=com',
        roles_ldap_filter => '(!(cn=P0*))',
      }
      keycloak_ldap_mapper { 'group for LDAP on test':
        type               => 'group-ldap-mapper',
        groups_dn          => 'ou=Groups,dc=example,dc=com',
        groups_ldap_filter => '(cn=P0*)',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'LDAP' }[0]
        expect(d['config']['usersDn']).to eq(['ou=People,dc=test'])
        expect(d['config']['connectionUrl']).to eq(['ldap://localhost:389'])
        expect(d['config']['userObjectClasses']).to eq(['posixAccount'])
        expect(d['config'].key?('customUserSearchFilter')).to eq(false)
        expect(d['config']['trustEmail']).to eq(['true'])
        expect(d['config']['fullSyncPeriod']).to eq(['60'])
        expect(d['config']['changedSyncPeriod']).to eq(['30'])
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
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'LDAP2':
        realm                     => 'test',
        users_dn                  => 'ou=People,dc=test',
        connection_url            => 'ldap://localhost:389',
        custom_user_search_filter => '(objectClass=posixAccount)',
        auth_type                 => 'simple',
        bind_dn                   => 'cn=read,ou=People,dc=test',
        bind_credential           => 'test',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has created a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'LDAP2' }[0]
        expect(d['config']['authType']).to eq(['simple'])
        expect(d['config']['bindDn']).to eq(['cn=read,ou=People,dc=test'])
        expect(d['config']['bindCredential'][0]).to match(%r{^[\*]+$})
      end
    end

    it 'has set bindCredential' do
      on hosts, "mysql keycloak -BN -e 'SELECT VALUE FROM COMPONENT_CONFIG WHERE NAME=\"bindCredential\" AND COMPONENT_ID=\"0d9e16dc-728d-547c-a0f5-fa0f3ca925a6\"'" do
        expect(stdout).to match(%r{^test$})
      end
    end
  end

  context 'updates ldap auth' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak_ldap_user_provider { 'LDAP':
        realm               => 'test',
        users_dn            => 'ou=People,dc=test',
        connection_url      => 'ldap://localhost:389',
        user_object_classes => ['posixAccount'],
        auth_type           => 'simple',
        bind_dn             => 'cn=read,ou=People,dc=test',
        bind_credential     => 'test',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'has updated a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'LDAP' }[0]
        expect(d['config']['authType']).to eq(['simple'])
        expect(d['config']['bindDn']).to eq(['cn=read,ou=People,dc=test'])
        expect(d['config']['bindCredential'][0]).to match(%r{^[\*]+$})
      end
    end

    it 'has set bindCredential' do
      on hosts, "mysql keycloak -BN -e 'SELECT VALUE FROM COMPONENT_CONFIG WHERE NAME=\"bindCredential\" AND COMPONENT_ID=\"bc7bc27f-39b8-5152-91c3-915d710fba35\"'" do
        expect(stdout).to match(%r{^test$})
      end
    end
  end

  context 'ensure => absent' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
      keycloak_ldap_mapper { 'full-name':
        ensure => 'absent',
        realm  => 'test',
        ldap   => 'LDAP',
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

  context 'creates freeipa user provider' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak::freeipa_user_provider { 'ipa.example.org':
        ensure          => 'present',
        realm           => 'test',
        bind_dn         => 'uid=ldapproxy,cn=sysaccounts,cn=etc,dc=example,dc=org',
        bind_credential => 'secret',
        users_dn        => 'cn=users,cn=accounts,dc=example,dc=org',
        priority        => 10,
        ldaps           => false,
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'creates freeipa ldap mappers' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'keycloak': }
      keycloak_realm { 'test': ensure => 'present' }
      keycloak::freeipa_user_provider { 'ipa.example.org':
        ensure          => 'present',
        realm           => 'test',
        bind_dn         => 'uid=ldapproxy,cn=sysaccounts,cn=etc,dc=example,dc=org',
        bind_credential => 'secret',
        users_dn        => 'cn=users,cn=accounts,dc=example,dc=org',
        priority        => 10,
        ldaps           => false,
      }
      keycloak::freeipa_ldap_mappers { 'ipa.example.org':
        realm     => 'test',
        groups_dn => 'cn=groups,cn=accounts,dc=example,dc=org',
        roles_dn  => 'cn=groups,cn=accounts,dc=example,dc=org',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'ID migration' do
    it 'sets up migration' do
      clean_pp = <<-EOS
      keycloak_realm { 'test':
        ensure => 'absent',
      }
      EOS
      before_pp = <<-EOS
      keycloak_realm { 'test':
        ensure => 'present',
      }
      keycloak_ldap_user_provider { 'LDAP on test':
        id                        => 'LDAP-test',
        users_dn                  => 'ou=People,dc=test',
        connection_url            => 'ldap://localhost:389',
        custom_user_search_filter => '(objectClass=posixAccount)',
      }
      keycloak_ldap_mapper { "first name for LDAP-test on test":
        ensure               => 'present',
        parent_id            => 'LDAP-test',
        type                 => 'user-attribute-ldap-mapper',
        user_model_attribute => 'firstName',
        ldap_attribute       => 'givenName',
      }
      EOS

      apply_manifest(clean_pp, catch_failures: true)
      apply_manifest(before_pp, catch_failures: true)
    end

    it 'has created a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'LDAP' }[0]
        expect(d['id']).to eq('LDAP-test')
      end
    end

    it 'has created a LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        # first name for LDAP-test on test
        d = data.select { |o| o['name'] == 'first name' && o['parentId'] == 'LDAP-test' }[0]
        expect(d['parentId']).to eq('LDAP-test')
      end
    end

    it 'performs migration' do
      after_pp = <<-EOS
      keycloak_realm { 'test':
        ensure => 'present',
      }
      keycloak_ldap_user_provider { 'LDAP-remove on test':
        ensure        => 'absent',
        resource_name => 'LDAP',
        id            => 'LDAP-test',
      }
      keycloak_ldap_user_provider { 'LDAP on test':
        users_dn                  => 'ou=People,dc=test',
        connection_url            => 'ldap://localhost:389',
        custom_user_search_filter => '(objectClass=posixAccount)',
      }
      keycloak_ldap_mapper { "first name for LDAP on test":
        ensure               => 'present',
        type                 => 'user-attribute-ldap-mapper',
        user_model_attribute => 'firstName',
        ldap_attribute       => 'givenName',
      }
      EOS

      apply_manifest(after_pp, catch_failures: true)
      apply_manifest(after_pp, catch_changes: true)
    end

    it 'has migrated a LDAP user provider' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        d = data.select { |o| o['name'] == 'LDAP' }[0]
        expect(d['id']).to eq('32c83a5e-b233-510f-a6a8-0edeccc900f6')
      end
    end

    it 'has migrated a LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        # first name for LDAP on test
        d = data.select { |o| o['name'] == 'first name' && o['parentId'] == '32c83a5e-b233-510f-a6a8-0edeccc900f6' }[0]
        expect(d['parentId']).to eq('32c83a5e-b233-510f-a6a8-0edeccc900f6')
      end
    end

    it 'has removed a LDAP mapper' do
      on hosts, '/opt/keycloak/bin/kcadm-wrapper.sh get components -r test' do
        data = JSON.parse(stdout)
        # first name for LDAP-test on test
        d = data.select { |o| o['name'] == 'first name' && o['parentId'] == 'LDAP-test' }[0]
        expect(d).to be_nil
      end
    end
  end
end
