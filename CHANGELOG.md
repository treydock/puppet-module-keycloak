# treydock-keycloak changelog

## [3.2.0](https://github.com/treydock/puppet-module-keycloak/tree/3.2.0) (2018-12-21)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.1.0...3.2.0)

**Implemented enhancements:**

- Support SSSD User Provider [\#42](https://github.com/treydock/puppet-module-keycloak/pull/42) ([treydock](https://github.com/treydock))
- Add enabled property to keycloak\_ldap\_user\_provider [\#41](https://github.com/treydock/puppet-module-keycloak/pull/41) ([treydock](https://github.com/treydock))

## [3.1.0](https://github.com/treydock/puppet-module-keycloak/tree/3.1.0) (2018-12-13)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.0.0...3.1.0)

**Implemented enhancements:**

- Bump dependency ranges for stdlib and mysql [\#40](https://github.com/treydock/puppet-module-keycloak/pull/40) ([treydock](https://github.com/treydock))
- Support Puppet 6 and drop support for Puppet 4 [\#39](https://github.com/treydock/puppet-module-keycloak/pull/39) ([treydock](https://github.com/treydock))
- Use beaker 4.x [\#37](https://github.com/treydock/puppet-module-keycloak/pull/37) ([treydock](https://github.com/treydock))

**Fixed bugs:**

- Fix keycloak\_ldap\_user\_provider bind\_credential property to be idempotent [\#38](https://github.com/treydock/puppet-module-keycloak/pull/38) ([treydock](https://github.com/treydock))

## [3.0.0](https://github.com/treydock/puppet-module-keycloak/tree/3.0.0) (2018-08-14)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.7.1...3.0.0)

**Merged pull requests:**

- BREAKING: Major overhaul to support Keycloak 4.x [\#32](https://github.com/treydock/puppet-module-keycloak/pull/32) ([treydock](https://github.com/treydock))
- Update module dependency version ranges [\#35](https://github.com/treydock/puppet-module-keycloak/pull/35) ([treydock](https://github.com/treydock))

**Implemented enhancements:**

- Support Keycloak 4.x [\#31](https://github.com/treydock/puppet-module-keycloak/issues/31)

## [2.7.1](https://github.com/treydock/puppet-module-keycloak/tree/2.7.1) (2018-08-14)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.7.0...2.7.1)

**Fixed bugs:**

- Update reference [\#36](https://github.com/treydock/puppet-module-keycloak/pull/36) ([treydock](https://github.com/treydock))

## [2.7.0](https://github.com/treydock/puppet-module-keycloak/tree/2.7.0) (2018-08-14)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.6.0...2.7.0)

**Implemented enhancements:**

- Oracle support [\#33](https://github.com/treydock/puppet-module-keycloak/pull/33) ([cborisa](https://github.com/cborisa))

## [2.6.0](https://github.com/treydock/puppet-module-keycloak/tree/2.6.0) (2018-07-20)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.5.0...2.6.0)

**Implemented enhancements:**

- Add search\_scope and custom\_user\_search\_filter properties to keycloak\_ldap\_user\_provider type [\#29](https://github.com/treydock/puppet-module-keycloak/pull/29) ([treydock](https://github.com/treydock))

**Closed issues:**

- Support customUserSearchFilter [\#25](https://github.com/treydock/puppet-module-keycloak/issues/25)

**Merged pull requests:**

- Use puppet-strings for documentation [\#30](https://github.com/treydock/puppet-module-keycloak/pull/30) ([treydock](https://github.com/treydock))
- Fix for keycloak\_protocol\_mapper type property and type unit test improvements [\#28](https://github.com/treydock/puppet-module-keycloak/pull/28) ([treydock](https://github.com/treydock))
- Explicitly define all type properties [\#27](https://github.com/treydock/puppet-module-keycloak/pull/27) ([treydock](https://github.com/treydock))
- Improve acceptance tests [\#26](https://github.com/treydock/puppet-module-keycloak/pull/26) ([treydock](https://github.com/treydock))

## [2.5.0](https://github.com/treydock/puppet-module-keycloak/tree/2.5.0) (2018-07-18)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.4.0...2.5.0)

**Implemented enhancements:**

- Support setting auth\_type=simple related properties for keycloak\_ldap\_user\_provider type [\#24](https://github.com/treydock/puppet-module-keycloak/pull/24) ([treydock](https://github.com/treydock))

**Closed issues:**

- bindDn and bindCredential for  keycloak\_ldap\_user\_provider [\#23](https://github.com/treydock/puppet-module-keycloak/issues/23)

## [2.4.0](https://github.com/treydock/puppet-module-keycloak/tree/2.4.0) (2018-06-04)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.3.1...2.4.0)

**Implemented enhancements:**

- Add keycloak\_api configuration type [\#22](https://github.com/treydock/puppet-module-keycloak/pull/22) ([treydock](https://github.com/treydock))

**Closed issues:**

- Are the types in this module compatible with biemond/wildfly? [\#20](https://github.com/treydock/puppet-module-keycloak/issues/20)

## [2.3.1](https://github.com/treydock/puppet-module-keycloak/tree/2.3.1) (2018-03-10)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.3.0...2.3.1)

**Fixed bugs:**

- Fix title patterns that use procs are not supported [\#21](https://github.com/treydock/puppet-module-keycloak/pull/21) ([alexjfisher](https://github.com/alexjfisher))

## [2.3.0](https://github.com/treydock/puppet-module-keycloak/tree/2.3.0) (2018-03-08)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.2.1...2.3.0)

**Implemented enhancements:**

- Allow keycloak\_protocol\_mapper attribute\_nameformat to be simpler values [\#18](https://github.com/treydock/puppet-module-keycloak/pull/18) ([treydock](https://github.com/treydock))
- Add SAML username protocol mapper to keycloak::client\_template [\#17](https://github.com/treydock/puppet-module-keycloak/pull/17) ([treydock](https://github.com/treydock))
- Support SAML role list protocol mapper [\#16](https://github.com/treydock/puppet-module-keycloak/pull/16) ([treydock](https://github.com/treydock))
- Add SAML support to keycloak\_protocol\_mapper and keycloak::client\_template [\#15](https://github.com/treydock/puppet-module-keycloak/pull/15) ([treydock](https://github.com/treydock))

**Fixed bugs:**

- Fix SAML username protocol mapper to match keycloak code [\#19](https://github.com/treydock/puppet-module-keycloak/pull/19) ([treydock](https://github.com/treydock))

## [2.2.1](https://github.com/treydock/puppet-module-keycloak/tree/2.2.1) (2018-02-27)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.2.0...2.2.1)

**Fixed bugs:**

- Do not show diff of files that may contain passwords [\#14](https://github.com/treydock/puppet-module-keycloak/pull/14) ([treydock](https://github.com/treydock))

## [2.2.0](https://github.com/treydock/puppet-module-keycloak/tree/2.2.0) (2018-02-26)
[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.1.0...2.2.0)

**Implemented enhancements:**

- Make management of the MySQL database optional [\#13](https://github.com/treydock/puppet-module-keycloak/pull/13) ([treydock](https://github.com/treydock))

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
