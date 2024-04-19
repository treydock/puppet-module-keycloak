# puppet-module-keycloak

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/keycloak.svg)](https://forge.puppetlabs.com/treydock/keycloak)
[![CI Status](https://github.com/treydock/puppet-module-keycloak/workflows/CI/badge.svg?branch=master)](https://github.com/treydock/puppet-module-keycloak/actions?query=workflow%3ACI)

#### Table of Contents

1. [Overview](#overview)
    * [Upgrade to 8.x](#upgrade-to-8x)
        * [Changes to LDAP user provider IDs](#changes-to-ldap-user-provider-ids)
    * [Supported Versions of Keycloak](#supported-versions-of-keycloak)
2. [Usage - Configuration options](#usage)
    * [Keycloak](#keycloak)
    * [Deploy SPI](#deploy-spi)
    * [Partial Import](#partial-import)
    * [keycloak_realm](#keycloak_realm)
    * [keycloak_role_mapping](#keycloak_role_mapping)
    * [keycloak_ldap_user_provider](#keycloak_ldap_user_provider)
    * [keycloak_ldap_mapper](#keycloak_ldap_mapper)
    * [keycloak_sssd_user_provider](#keycloak_sssd_user_provider)
    * [keycloak_client](#keycloak_client)
    * [keycloak::client_scope::oidc](#keycloakclient_scopeoidc)
    * [keycloak::client_scope::saml](#keycloakclient_scopesaml)
    * [keycloak_client_scope](#keycloak_client_scope)
    * [keycloak_protocol_mapper](#keycloak_protocol_mapper)
    * [keycloak_client_protocol_mapper](#keycloak_client_protocol_mapper)
    * [keycloak_identity_provider](#keycloak_identity_provider)
    * [Keycloak Flows](#keycloak-flows)
    * [keycloak_api](#keycloak_api)
    * [keycloak_required_action](#keycloak_required_action)
3. [Reference - Parameter and detailed reference to all options](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)

## Overview

The keycloak module allows easy installation and management of Keycloak.

### Upgrade to 8.x

This module underwent major changes in the 8.0.0 release to support Keycloak that uses Quarkus.
The initial 8.0.0 release of this module only supports Keycloak 18.x.

Numerous parameters were changed or removed. Below is a list of the changes to parameters as well as some behavior changes.

**Parameters removed**

* `service_hasstatus`, `service_hasrestart`
* `management_bind_address`
* `java_opts_append`
* `wildfly_user`, `wildfly_user_password`
* `datasource_package`, `datasource_jar_source`, `datasource_jar_filename`, `datasource_module_source`, `datasource_xa_class`
* `proxy_https`
* `truststore_hostname_verification_policy`
* `theme_static_max_age`, `theme_cache_themes`, `theme_cache_templates`
* `operating_mode`, `enable_jdbc_ping`, `jboss_bind_public_address`, `jboss_bind_private_address`
* `master_address`, `server_name`, `role`, `user_cache`
* `tech_preview_features`
* `auto_deploy_exploded`, `auto_deploy_zipped`
* `syslog`, `syslog_app_name`, `syslog_facility`, `syslog_hostname`, `syslog_level`
* `syslog_port`, `syslog_server_address`, `syslog_format`

**Parameters renamed**

* `service_bind_address` renamed to `http_host` and now defined in keycloak.conf instead of the systemd unit file
* `manage_datasource` renamed to `manage_db`
* `datasource_driver` renamed to `db`
* `datasource_host` renamed to `db_url_host`
* `datasource_port` renamed to `db_url_port`
* `datasource_url` renamed to `db_url`
* `datasource_dbname` renamed to `db_url_database`
* `datasource_username` renamed to `db_username`
* `datasource_password` renamed to `db_password`
* `mysql_database_charset` renamed to `db_charset`
* `auth_url_path` renamed to `validator_test_url` and default value changed

**Parameters added**

* `java_declare_method` to make it easier for EL platforms to deploy working Keycloak with correct Java
* `java_package`, `java_home`, `java_alternative_path`, `java_alternative`
* `start_command`
* `configs`
* `hostname`, `http_enabled`, `http_host`, `https_port`, `proxy`
* `manage_db_server`
* `features`
* `features_disabled`
* `providers_purge`

**Behavior changes**

The SSSD parameters are no longer tested and likely won't work.  If you use the SSSD user provider and SSSD related parameters, please open an issue on this repo.

This module no longer makes copies for DB driver jar files or install Java bindings, they are not necessary.

When `db` is set to `mariadb`, `mysql` or `postgres` this module will by default install the database server to the Keycloak host. If you run a remote DB server for Keycloak, set `manage_db_server` and `manage_db` to `false`.

There is no longer a need to define cluster or domain modes in the Quarkus deployment, all related functionality is removed.

Some basic configuration options are exposed using parameters but most configuration options for Keycloak will need to be passed into the `configs` parameter.

Drop Debian 9 support due to OS repos not having Java 11.

#### Changes to LDAP user provider IDs

If you had `keycloak_ldap_user_provider` resources defined the mechanism for defining the ID has changed and requires some migration. Also the `ldap` property for any `keycloak_ldap_mapper` resources will have to be adjusted.

**WARNING** The LDAP user provider ID is used to create user IDs for LDAP users. These will change if the ID is changed. This is to prevent messages such as this: `The given key is not a valid key per specification, future migration might fail: f:OSC-LDAP-osc:tdockendorf`. If you wish to keep the old style IDs you must provide the `id` parameter as `$ldap-$realm` to maintain old IDs.

It's advised to either [Migrate to new IDs](#migrate-to-new-ids) or [Keep old IDs](#keep-old-ids)

##### Migrate to new IDs

**Changes**

* Define old `keycloak_ldap_user_provider` resource as absent with new name and setting `id` and `resource_name`.
* Define same `keycloak_ldap_user_provider` resource to get created with new ID
* Update `keycloak_ldap_mapper` resources to point to just name of `keycloak_ldap_user_provider`.

**Before:**

```puppet
keycloak_ldap_user_provider { 'LDAP on test':
  users_dn                  => 'ou=People,dc=test',
  connection_url            => 'ldap://localhost:389',
  custom_user_search_filter => '(objectClass=posixAccount)',
}
keycloak_ldap_mapper { "first name for LDAP-test on test":
  ensure               => 'present',
  type                 => 'user-attribute-ldap-mapper',
  user_model_attribute => 'firstName',
  ldap_attribute       => 'givenName',
}
```

**After:**

```
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
```

##### Keep old IDs

If you wish to avoid re-creating `keycloak_ldap_user_provider` and `keycloak_ldap_mapper` resources then the ID parameters must be defined.

For `keycloak_ldap_user_provider` ensure the `id` property is set to match the old pattern. If name was `LDAP` and realm `test` or name was componsite `LDAP on test` then set `id` to `LDAP-test`.

For `keycloak_ldap_mapper` ensure the `parent_id` property is set to point to old ID for associated `keycloak_ldap_user_provider`. If the `ldap` value is `LDAP` and `realm` is `test` or composite name is `first name for LDAP on test` then ensure `parent_id` is set to `LDAP-test`.

### Supported Versions of Keycloak

Currently this module supports Keycloak version 12.x.
This module may work on earlier versions but this is the only version tested.

| Keycloak Version | Keycloak Puppet module versions |
| ---------------- | ------------------------------- |
| 3.x              | 2.x                             |
| 4.x - 6.x        | 3.x                             |
| 6.x - 8.x        | 4.x - 5.x                       |
| 8.x - 12.x       | 6.x                             |
| 12.x - 16.x      | 7.x                             |
| 18.x             | 8.x                             |
| 19.x - 21.x      | 9.x                             |
| 21.x             | 10.x                            |
| 22.x - 24.x      | 11.x                            |

## Usage

### keycloak

Install Keycloak using default `dev-file` database.

```puppet
class { 'keycloak': }
```

Install a specific version of Keycloak.

```puppet
class { 'keycloak':
  version => '22.0.0',
  db      => 'mariadb',
}
```

Upgrading Keycloak version works by changing `version` parameter as long as the `db` parameter is not the default of `dev-file`. An upgrade involves installing the new version without touching the old version, updating the symlink which defaults to `/opt/keycloak`, applying all changes to new version and then restarting the `keycloak` service.

If the previous `version` was `22.0.0` using the following will upgrade to `23.0.0`:

```puppet
class { 'keycloak':
  version => '23.0.0',
  db      => 'mariadb',
}
```

Install keycloak and use a local MariaDB server for database storage

```puppet
include mysql::server
class { 'keycloak':
  db              => 'mariadb',
  db_url_host     => 'localhost',
  db_url_port     => 3306,
  db_url_database => 'keycloak',
  db_username     => 'keycloak',
  db_password     => 'foobar',
}
```

The following example can be used to configure keycloak with a local PostgreSQL server.

```puppet
include postgresql::server
class { 'keycloak':
    db              => 'postgres',
    db_url_host     => 'localhost',
    db_url_port     => 5432,
    db_url_database => 'keycloak',
    db_username     => 'keycloak',
    db_password     => 'foobar',
}
```

Configure a SSL certificate truststore and add a LDAP server's certificate to the truststore.

```puppet
class { 'keycloak':
  truststore          => true,
  truststore_password => 'supersecret',
}
keycloak::truststore::host { 'ldap1.example.com':
  certificate => '/etc/openldap/certs/0a00000.0',
}
```

Setup Keycloak to proxy through Apache HTTPS.

```puppet
class { 'keycloak':
  http_host => '127.0.0.1',
  proxy     => 'edge',
}
apache::vhost { 'idp.example.com':
  servername          => 'idp.example.com',
  port                => '443',
  ssl                 => true,
  manage_docroot      => false,
  docroot             => '/var/www/html',
  proxy_preserve_host => true,
  proxy_add_headers   => true,
  proxy_pass          => [
    {'path' => '/', 'url' => 'http://localhost:8080/'}
  ],
  request_headers     => [
    'set X-Forwarded-Proto "https"',
    'set X-Forwarded-Port "443"'
  ],
  ssl_cert            => '/etc/pki/tls/certs/idp.example.com/crt',
  ssl_key             => '/etc/pki/tls/private/idp.example.com.key',
}
```

**NOTE:** Can set `hostname` parameter to `unset` if you wish for that configuration to not be set in the Keycloak configuration if you wish for Keycloak to not use strict hostname checking and respond to multiple hostnames.

### Deploy SPI

A simple example of deploying a custom SPI from a URL:

```puppet
keycloak::spi_deployment { 'duo-spi':
  ensure        => 'present',
  deployed_name => 'DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar',
  source        => 'https://github.com/instipod/DuoUniversalKeycloakAuthenticator/releases/download/1.0.5/DuoUniversalKeycloakAuthenticator-jar-with-dependencies-1.0.5.jar',
}
```

The `source` can be a URL or a file path like `/tmp/foo.jar` or prefixed with `file://` or `puppet://`

The following example will deploy a custom SPI then check the Keycloak API for the resource to exist.
This is useful to ensure SPI is loaded into Keycloak before attempting to add custom resources.

```puppet
keycloak::spi_deployment { 'duo-spi':
  deployed_name => 'DuoUniversalKeycloakAuthenticator-jar-with-dependencies.jar',
  source        => 'https://github.com/instipod/DuoUniversalKeycloakAuthenticator/releases/download/1.0.4/DuoUniversalKeycloakAuthenticator-jar-with-dependencies-1.0.4.jar',
  test_url      => 'authentication/authenticator-providers',
  test_key      => 'id',
  test_value    => 'duo-universal',
  test_realm    => 'test',
  test_before   => [
    'Keycloak_flow[form-browser-with-duo]',
    'Keycloak_flow_execution[duo-universal under form-browser-with-duo on test]',
  ],
}
```

### Partial Import

This module supports [Importing data from exported JSON files](https://www.keycloak.org/docs/latest/server_admin/index.html#importing-a-realm-from-exported-json-file) via the `keycloak::partial_import` defined type.

Example of importing a JSON file into the `test` realm:

```puppet
keycloak::partial_import { 'mysettings':
  realm              => 'test',
  if_resource_exists => 'SKIP',
  source             => 'puppet:///modules/profile/keycloak/mysettings.json',
}
```

**NOTE:** By default the `keycloak::partial_import` defined type will require the `Keycloak_realm` resource used for the `realm` parameter. If you manage the realm a different way, pass `require_realm => false`.

### keycloak_realm

Define a Keycloak realm that uses username and not email for login and to use a local branded theme.

```puppet
keycloak_realm { 'test':
  ensure                   => 'present',
  remember_me              => true,
  login_with_email_allowed => false,
  login_theme              => 'my_theme',
}
```

**NOTE:** If the flow properties such as `browser_flow` are changed from their defaults then this value will not be set when a realm is first created. The value will also not be updated if the flow does not exist. For new realms you will have to run Puppet twice in order to create the flows then update the realm setting.

### keycloak\_role\_mapping

Manage realm role mappings for users and groups. Example:

    keycloak_role_mapping { 'roles for john on master':
      realm       => 'master',
      name        => 'john',
      realm_roles => ['role1', 'role2'],
    }
    
    keycloak_role_mapping { 'roles for mygroup on master':
      realm        => 'master',
      name         => 'mygroup',
      group        => true,
      realm_roles  => ['role1'],
    }

### keycloak\_ldap\_user_provider

Define a LDAP user provider so that authentication can be performed against LDAP.  The example below uses two LDAP servers, disables importing of users and assumes the SSL certificates are trusted and do not require being in the truststore.

 ```puppet
keycloak_ldap_user_provider { 'LDAP on test':
  ensure             => 'present',
  users_dn           => 'ou=People,dc=example,dc=com',
  connection_url     => 'ldaps://ldap1.example.com:636 ldaps://ldap2.example.com:636',
  import_enabled     => false,
  use_truststore_spi => 'never',
}
```

If you're using FreeIPA you can use a defined resource that wraps keycloak\_ldap\_user\_provider:

```puppet
keycloak::freeipa_user_provider { 'ipa.example.org':
  ensure          => 'present',
  realm           => 'EXAMPLE.ORG',
  bind_dn         => 'uid=ldapproxy,cn=sysaccounts,cn=etc,dc=example,dc=org',
  bind_credential => 'secret',
  users_dn        => 'cn=users,cn=accounts,dc=example,dc=org',
  priority        => 10,
}
```

### keycloak\_ldap_mapper

Use the LDAP attribute 'gecos' as the full name attribute.

```puppet
keycloak_ldap_mapper { 'full name for LDAP-test on test:
  ensure         => 'present',
  resource_name  => 'full name',
  type           => 'full-name-ldap-mapper',
  ldap_attribute => 'gecos',
}
```

If you're using FreeIPA you can use a defined resource that adds all the
required attribute mappings automatically:

```puppet
keycloak::freeipa_ldap_mappers { 'ipa.example.org':
  realm            => 'EXAMPLE.ORG',
  groups_dn        => 'cn=groups,cn=accounts,dc=example,dc=org',
  roles_dn         => 'cn=groups,cn=accounts,dc=example,dc=org'
}
```

### keycloak\_sssd\_user\_provider

**WARNING** This feature is no longer tested and likely stopped working when Keycloak began requiring Java 11+. If you rely on this feature, please open an issue or pull request. Likely need to build jna from source.

Define SSSD user provider.  **NOTE** This type requires that SSSD be properly configured and Keycloak service restarted after SSSD ifp service is setup.  Also requires `keycloak` class be called with `with_sssd_support` set to `true`.

```puppet
keycloak_sssd_user_provider { 'SSSD on test':
  ensure => 'present',
}
```

### keycloak_client

Register a client.

```puppet
keycloak_client { 'www.example.com':
  ensure          => 'present',
  realm           => 'test',
  redirect_uris   => [
    "https://www.example.com/oidc",
    "https://www.example.com",
  ],
  client_template => 'oidc-clients',
  secret          => 'supersecret',
}
```

### keycloak::client_scope::oidc

Defined type that can be used to define both `keycloak_client_scope` and `keycloak_protocol_mapper` resources for OpenID Connect. 

```puppet
keycloak::client_scope::oidc { 'oidc-clients':
  realm => 'test',
}
```

### keycloak::client_scope::saml

Defined type that can be used to define both `keycloak_client_scope` and `keycloak_protocol_mapper` resources for SAML. 

```puppet
keycloak::client_scope::saml { 'saml-clients':
  realm => 'test',
}
```

### keycloak\_client_scope

Define a Client Scope of `email` for realm `test` in Keycloak:

```puppet
keycloak_client_scope { 'email on test':
  protocol => 'openid-connect',
}
```

### keycloak\_protocol_mapper

Associate a Protocol Mapper to a given Client Scope.  The name in the following example will add the `email` protocol mapper to client scope `oidc-email` in the realm `test`.

```puppet
keycloak_protocol_mapper { "email for oidc-email on test":
  claim_name     => 'email',
  user_attribute => 'email',
}
```

### keycloak\_client\_protocol\_mapper

Add `email` protocol mapper to `test.example.com` client in realm `test`

```puppet
keycloak_client_protocol_mapper { "email for test.example.com on test":
  claim_name     => 'email',
  user_attribute => 'email',
}
```

### keycloak\_identity\_provider

Add `cilogon` identity provider to `test` realm

```puppet
keycloak_identity_provider { 'cilogon on test':
  ensure                        => 'present',
  display_name                  => 'CILogon',
  provider_id                   => 'oidc',
  first_broker_login_flow_alias => 'browser',
  client_id                     => 'cilogon:/client_id/foobar',
  client_secret                 => 'supersecret',
  user_info_url                 => 'https://cilogon.org/oauth2/userinfo',
  token_url                     => 'https://cilogon.org/oauth2/token',
  authorization_url             => 'https://cilogon.org/authorize',
}
```

### Keycloak Flows

The following is an example of deploying a custom Flow.
The name for the top level flow is `$alias on $realm`
The name for an execution is `$provider under $flow on $realm`.
The name for the flow under a top level flow is `$alias under $flow_alias on $realm`.

```puppet
keycloak_flow { 'browser-with-duo on test':
  ensure => 'present',
}
keycloak_flow_execution { 'auth-cookie under browser-with-duo on test':
  ensure       => 'present',
  configurable => false,
  display_name => 'Cookie',
  index        => 0,
  requirement  => 'ALTERNATIVE',
}
keycloak_flow_execution { 'identity-provider-redirector under browser-with-duo on test':
  ensure       => 'present',
  configurable => true,
  display_name => 'Identity Provider Redirector',
  index        => 1,
  requirement  => 'ALTERNATIVE',
}
keycloak_flow { 'form-browser-with-duo under browser-with-duo on test':
  ensure      => 'present',
  index       => 2,
  requirement => 'ALTERNATIVE',
  top_level   => false,
}
keycloak_flow_execution { 'auth-username-password-form under form-browser-with-duo on test':
  ensure       => 'present',
  configurable => false,
  display_name => 'Username Password Form',
  index        => 0,
  requirement  => 'REQUIRED',
}
keycloak_flow_execution { 'duo-universal under form-browser-with-duo on test':
  ensure       => 'present',
  configurable => true,
  display_name => 'Duo Universal MFA',
  alias        => 'Duo',
  config       => {
    "duoApiHostname"    => "api-foo.duosecurity.com",
    "duoSecretKey"      => "secret",
    "duoIntegrationKey" => "foo-ikey",
    "duoGroups"         => "duo"
  },
  requirement  => 'REQUIRED',
  index        => 1,
}
```

### keycloak\_api

The keycloak_api type can be used to define how this module's types access the Keycloak API if this module is only used for the types/providers and the module's `kcadm-wrapper.sh` is not installed.

 ```puppet
keycloak_api { 'keycloak'
  install_dir => '/opt/keycloak',
  server     => 'http://localhost:8080/auth',
  realm      => 'master',
  user       => 'admin',
  password   => 'changeme',
}
```

The path for `install_dir` will be joined with `bin/kcadm.sh` to produce the full path to `kcadm.sh`.

### keycloak\_required\_action

The keycloak_required_action type can be used to define actions a user must perform during the authentication process.
A user will not be able to complete the authentication process until these actions are complete. For instance, change a one-time password, accept T&C, etc.

The name for an action is `$alias on $realm`.

**Important**: actions from puppet config and from a server are matched based on a combination of alias and realm, so edition of aliases is not supported.

 ```puppet
# Minimal example
keycloak_required_action { 'VERIFY_EMAIL on master':
  ensure => present,
  provider_id => 'webauthn-register',
}

# Full example

keycloak_required_action { 'webauthn-register on master':
  ensure => present,
  provider_id => 'webauthn-register',
  display_name => 'Webauthn Register',
  default => true,
  enabled => true,
  priority => 1,
  config => {
    'something' => 'true', # keep in mind that keycloak only supports strings for both keys and values
    'smth else' => '1',
  },
}
```

## Reference

[http://treydock.github.io/puppet-module-keycloak/](http://treydock.github.io/puppet-module-keycloak/)

## Limitations

This module has been tested on:

* RedHat/Rocky/AlmaLinux 8 x86_64
* RedHat/Rocky/AlmaLinux 9 x86_64
* Debian 11 x86_64
* Ubuntu 20.04 x86_64
* Ubuntu 22.04 x86_64

## UUID Generation

```
bundle exec irb
2.5.1 :001 > require File.expand_path(File.join(File.dirname(__FILE__), 'lib/puppet/provider/keycloak_api'))
 => true 
2.5.1 :002 > Puppet::Provider::KeycloakAPI.name_uuid('LDAP')
 => "bc7bc27f-39b8-5152-91c3-915d710fba35" 
```
