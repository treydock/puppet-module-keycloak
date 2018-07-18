# puppet-module-keycloak

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/keycloak.svg)](https://forge.puppetlabs.com/treydock/keycloak)
[![Build Status](https://travis-ci.org/treydock/puppet-module-keycloak.png)](https://travis-ci.org/treydock/puppet-module-keycloak)

#### Table of Contents

1. [Overview](#overview)
2. [Usage - Configuration options](#usage)
3. [Reference - Parameter and detailed reference to all options](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Overview

The keycloak module allows easy installation and management of Keycloak.

## Usage

### keycloak

Install Keycloak using default database storage.

    class { 'keycloak': }

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

### keycloak::client_template

Defined type that can be used to define both `keycloak_client_template` and `keycloak_protocol_mapper` resources. The example below will define a client template and several protocol mappers that are built into keycloak.

    keycloak::client_template { 'oidc-clients':
      realm => 'test',
    }

### keycloak\_client_template

Define a Client Template in Keycloak:

    keycloak_client_template { 'oidc-clients':
      realm              => 'test',
      resource_name      => 'oidc-clients',
      protocol           => 'openid-connect',
      full_scope_allowed => true,
    }

### keycloak\_protocol_mapper

Associate a Protocol Mapper to a given template.  The name in the following example will add the `email` protocol mapper to client template `oidc-clients` in the realm `test`.

    keycloak_protocol_mapper { "email for oidc-clients on test":
      consent_text   => '${email}',
      claim_name     => 'email',
      user_attribute => 'email',
    }

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

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake test

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake beaker
