# treydock-keycloak changelog

## [2.1.0](https://github.com/treydock/puppet-module-keycloak/tree/2.1.0) (2018-02-22)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.0.1...2.1.0)

**Implemented enhancements:**

- Increase minimum java dependency to 2.2.0 to to support Debian 9. Update unit tests to test all supported OSes [\#12](https://github.com/treydock/puppet-module-keycloak/pull/12) ([treydock](https://github.com/treydock))
- Symlink instead of copy mysql connector. puppetlabs/mysql 5 compatibility [\#11](https://github.com/treydock/puppet-module-keycloak/pull/11) ([NITEMAN](https://github.com/NITEMAN))
- Add support for http port configuration [\#9](https://github.com/treydock/puppet-module-keycloak/pull/9) ([NITEMAN](https://github.com/NITEMAN))
- Add Debian 9 support [\#8](https://github.com/treydock/puppet-module-keycloak/pull/8) ([NITEMAN](https://github.com/NITEMAN))

**Fixed bugs:**

- Fix ownership of install dir [\#10](https://github.com/treydock/puppet-module-keycloak/pull/10) ([NITEMAN](https://github.com/NITEMAN))

## [2.0.1](https://github.com/treydock/puppet-module-keycloak/tree/2.0.1) (2017-12-18)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.0.0...2.0.1)

**Fixed bugs:**

- Fix configuration order when proxy\_https is true [\#7](https://github.com/treydock/puppet-module-keycloak/pull/7) ([treydock](https://github.com/treydock))

## [2.0.0](https://github.com/treydock/puppet-module-keycloak/tree/2.0.0) (2017-12-11)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/1.0.0...2.0.0)

**Implemented enhancements:**

- BREAKING: Remove deprecated defined types [\#6](https://github.com/treydock/puppet-module-keycloak/pull/6) ([treydock](https://github.com/treydock))
- Add always\_read\_value\_from\_ldap property to keycloak\_ldap\_mapper [\#5](https://github.com/treydock/puppet-module-keycloak/pull/5) ([treydock](https://github.com/treydock))
- BREAKING: Set default version to 3.4.1.Final [\#4](https://github.com/treydock/puppet-module-keycloak/pull/4) ([treydock](https://github.com/treydock))
- BREAKING: Drop Puppet 3 support [\#3](https://github.com/treydock/puppet-module-keycloak/pull/3) ([treydock](https://github.com/treydock))

## [1.0.0](https://github.com/treydock/puppet-module-keycloak/tree/1.0.0) (2017-09-05)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/0.0.1...1.0.0)

Initial release using custom types and providers

Changes since 0.0.1:
* Add keycloak_realm type that deprecates keycloak::realm
* Add keycloak\_ldap\_user\_provider that deprecates keycloak::user\_federation::ldap
* Add keycloak\_ldap\_mapper that deprecates keycloak::user\_federation::ldap_mapper
* Add keycloak_client that deprecates keycloak::client
* Add keycloak\_client\_template and keycloak\_protocol\_mapper types
* Update keycloak::client_template to use keycloak\_client\_template and keycloak\_protocol\_mapper types
* Add symlink /opt/keycloak that points to currently managed keycloak install
* Add kcadm-wrapper.sh to install's bin directory which is used by custom types/providers

## [0.0.1](https://github.com/treydock/puppet-module-keycloak/tree/0.0.1) (2017-08-11)

Initial release
