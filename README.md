# puppet-module-keycloak

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/keycloak.svg)](https://forge.puppetlabs.com/treydock/keycloak)
[![Build Status](https://travis-ci.org/treydock/puppet-module-keycloak.png)](https://travis-ci.org/treydock/puppet-module-keycloak)

#### Table of Contents

1. [Overview](#overview)
    * [Upgrade to 3.x](#upgrade-to-3x)
    * [Supported Versions of Keycloak](#supported-versions-of-keycloak)
2. [Usage - Configuration options](#usage)
3. [Reference - Parameter and detailed reference to all options](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)

## Overview

The keycloak module allows easy installation and management of Keycloak.

### Supported Versions of Keycloak

| Keycloak Version | Keycloak Puppet module versions |
| ---------------- | ------------------------------- |
| 3.x              | 2.x                             |
| 4.x - 6.x        | 3.x                             |
| 6.x - 7.x        | 4.x - 5.x                       |


## Usage

### keycloak

Install Keycloak using default database storage.

    class { 'keycloak': }

Install a specific version of Keycloak.

```puppet
class { 'keycloak':
  version => '6.0.1',
}
```

Upgrading Keycloak version works by changing `version` parameter as long as the `datasource_driver` is not the default of `h2`. An upgrade involves installing the new version without touching the old version, updating the symlink which defaults to `/opt/keycloak`, applying all changes to new version and then restarting the `keycloak` service.

If the previous `version` was `6.0.1` using the following will upgrade to `7.0.0`:

```puppet
class { 'keycloak':
  version => '7.0.0',
}
```

Install keycloak and use a local MySQL server for database storage

    include mysql::server
    class { 'keycloak':
      datasource_driver   => 'mysql',
      datasource_host     => 'localhost',
      datasource_port     => 3306,
      datasource_dbname   => 'keycloak',
      datasource_username => 'keycloak',
      datasource_password => 'foobar',
    }
    
The following example can be used to configure keycloak with a local PostgreSQL server.

    include postgresql::server
    class { 'keycloak':
        datasource_driver     => 'postgresql',
        datasource_host       => 'localhost',
        datasource_port       => 5432,
        datasource_dbname     => 'keycloak',
        datasource_username   => 'keycloak',
        datasource_password   => 'foobar',
    }

Configure a SSL certificate truststore and add a LDAP server's certificate to the truststore.

    class { 'keycloak':
      truststore                              => true,
      truststore_password                     => 'supersecret',
      truststore_hostname_verification_policy => 'STRICT',
    }
    keycloak::truststore::host { 'ldap1.example.com':
      certificate => '/etc/openldap/certs/0a00000.0',
    }

Setup Keycloak to proxy through Apache HTTPS.

    class { 'keycloak':
      proxy_https => true
    }
    apache::vhost { 'idp.example.com':
      servername => 'idp.example.com',
      port        => '443',
      ssl         => true,
      manage_docroot  => false,
      docroot         => '/var/www/html',
      proxy_preserve_host => true,
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

Setup a host for theme development so that theme changes don't require a service restart, not recommended for production.

    class { 'keycloak':
      theme_static_max_age  => -1,
      theme_cache_themes    => false,
      theme_cache_templates => false,
    }

### keycloak_realm

Define a Keycloak realm that uses username and not email for login and to use a local branded theme.

    keycloak_realm { 'test':
      ensure                   => 'present',
      remember_me              => true,
      login_with_email_allowed => false,
      login_theme              => 'my_theme',
    }

### keycloak\_ldap\_user_provider

Define a LDAP user provider so that authentication can be performed against LDAP.  The example below uses two LDAP servers, disables importing of users and assumes the SSL certificates are trusted and do not require being in the truststore.

    keycloak_ldap_user_provider { 'LDAP on test':
      ensure             => 'present',
      users_dn           => 'ou=People,dc=example,dc=com',
      connection_url     => 'ldaps://ldap1.example.com:636 ldaps://ldap2.example.com:636',
      import_enabled     => false,
      use_truststore_spi => 'never',
    }

**NOTE** The `Id` for the above resource would be `LDAP-test` where the format is `${resource_name}-${realm}`.

### keycloak\_ldap_mapper

Use the LDAP attribute 'gecos' as the full name attribute.

    keycloak_ldap_mapper { 'full name for LDAP-test on test:
      ensure         => 'present',
      resource_name  => 'full name',
      type           => 'full-name-ldap-mapper',
      ldap_attribute => 'gecos',
    }

### keycloak\_sssd\_user\_provider

Define SSSD user provider.  **NOTE** This type requires that SSSD be properly configured and Keycloak service restarted after SSSD ifp service is setup.  Also requires `keycloak` class be called with `with_sssd_support` set to `true`.

    keycloak_sssd_user_provider { 'SSSD on test':
      ensure => 'present',
    }

### keycloak_client

Register a client.

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

### keycloak::client_scope::oidc

Defined type that can be used to define both `keycloak_client_scope` and `keycloak_protocol_mapper` resources for OpenID Connect. 

    keycloak::client_scope::oidc { 'oidc-clients':
      realm => 'test',
    }

### keycloak::client_scope::saml

Defined type that can be used to define both `keycloak_client_scope` and `keycloak_protocol_mapper` resources for SAML. 

    keycloak::client_scope::saml { 'saml-clients':
      realm => 'test',
    }

### keycloak\_client_scope

Define a Client Scope of `email` for realm `test` in Keycloak:

    keycloak_client_scope { 'email on test':
      protocol => 'openid-connect',
    }

### keycloak\_protocol_mapper

Associate a Protocol Mapper to a given Client Scope.  The name in the following example will add the `email` protocol mapper to client scope `oidc-email` in the realm `test`.

    keycloak_protocol_mapper { "email for oidc-email on test":
      claim_name     => 'email',
      user_attribute => 'email',
    }

### keycloak\_client\_protocol\_mapper

Add `email` protocol mapper to `test.example.com` client in realm `test`

    keycloak_client_protocol_mapper { "email for test.example.com on test":
      claim_name     => 'email',
      user_attribute => 'email',
    }

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

### keycloak\_api

The keycloak_api type can be used to define how this module's types access the Keycloak API if this module is only used for the types/providers and the module's `kcadm-wrapper.sh` is not installed.

    keycloak_api { 'keycloak'
      install_base => '/opt/keycloak',
      server       => 'http://localhost:8080/auth',
      realm        => 'master',
      user         => 'admin',
      password     => 'changeme',
    }

The path for `install_base` will be joined with `bin/kcadm.sh` to produce the full path to `kcadm.sh`.

## Reference

[http://treydock.github.io/puppet-module-keycloak/](http://treydock.github.io/puppet-module-keycloak/)

## Limitations

This module has been tested on:

* CentOS 7 x86_64
* Debian 9 x86_64
* RedHat 7 x86_64
