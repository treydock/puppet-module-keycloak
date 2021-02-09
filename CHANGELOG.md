# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v6.25.2](https://github.com/treydock/puppet-module-keycloak/tree/v6.25.2) (2021-02-09)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.25.1...v6.25.2)

### Fixed

- Fix missing IntegerProperty when keycloak\_ldap\_user\_provider [\#182](https://github.com/treydock/puppet-module-keycloak/pull/182) ([ZloeSabo](https://github.com/ZloeSabo))

## [v6.25.1](https://github.com/treydock/puppet-module-keycloak/tree/v6.25.1) (2021-01-07)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.25.0...v6.25.1)

### Fixed

- Ensure systemd logging for Keycloak uses more meaningful syslog identifier [\#179](https://github.com/treydock/puppet-module-keycloak/pull/179) ([treydock](https://github.com/treydock))
- Fix keycloak\_client to not warn when theme is not set [\#178](https://github.com/treydock/puppet-module-keycloak/pull/178) ([treydock](https://github.com/treydock))

## [v6.25.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.25.0) (2020-12-30)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.24.0...v6.25.0)

### Added

- Add client\_protocol\_mappers parameter [\#177](https://github.com/treydock/puppet-module-keycloak/pull/177) ([treydock](https://github.com/treydock))

## [v6.24.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.24.0) (2020-12-22)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.23.0...v6.24.0)

### Added

- Support Keycloak 12 [\#176](https://github.com/treydock/puppet-module-keycloak/pull/176) ([treydock](https://github.com/treydock))

## [v6.23.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.23.0) (2020-12-08)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.22.0...v6.23.0)

### Added

- Support saml-group-membership-mapper [\#171](https://github.com/treydock/puppet-module-keycloak/pull/171) ([mattock](https://github.com/mattock))
- Add convenience define for setting up FreeIPA LDAP mappers [\#170](https://github.com/treydock/puppet-module-keycloak/pull/170) ([mattock](https://github.com/mattock))
- PDK Update - Use Github Actions [\#169](https://github.com/treydock/puppet-module-keycloak/pull/169) ([treydock](https://github.com/treydock))
- Add convenience wrapper for setting up FreeIPA ldap user providers [\#135](https://github.com/treydock/puppet-module-keycloak/pull/135) ([mattock](https://github.com/mattock))

### Fixed

- Fix puppet-lint warning [\#172](https://github.com/treydock/puppet-module-keycloak/pull/172) ([mattock](https://github.com/mattock))

## [v6.22.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.22.0) (2020-11-23)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.21.0...v6.22.0)

### Added

- Support realm remember\_me parameters [\#168](https://github.com/treydock/puppet-module-keycloak/pull/168) ([mattock](https://github.com/mattock))

### Fixed

- Vagrant: install puppetlabs-concat during provisioning [\#167](https://github.com/treydock/puppet-module-keycloak/pull/167) ([mattock](https://github.com/mattock))

## [v6.21.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.21.0) (2020-10-30)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.20.0...v6.21.0)

### Added

- Fixing wrong filename in module.xml for datasource oracle [\#153](https://github.com/treydock/puppet-module-keycloak/pull/153) ([zaeh](https://github.com/zaeh))

## [v6.20.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.20.0) (2020-10-27)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.19.0...v6.20.0)

### Added

- add oidc-usermodel-attribute-mapper [\#166](https://github.com/treydock/puppet-module-keycloak/pull/166) ([aba-rechsteiner](https://github.com/aba-rechsteiner))
- Support oidc-usermodel-client-role-mapper type in client protocol mapper [\#165](https://github.com/treydock/puppet-module-keycloak/pull/165) ([mattock](https://github.com/mattock))

## [v6.19.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.19.0) (2020-10-07)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.18.0...v6.19.0)

### Added

- Enable roles management at realm and client level [\#164](https://github.com/treydock/puppet-module-keycloak/pull/164) ([anlambert](https://github.com/anlambert))
- Add more realm login related properties [\#163](https://github.com/treydock/puppet-module-keycloak/pull/163) ([anlambert](https://github.com/anlambert))

## [v6.18.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.18.0) (2020-09-25)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.17.0...v6.18.0)

### Added

- Support flow overrides on clients [\#161](https://github.com/treydock/puppet-module-keycloak/pull/161) ([treydock](https://github.com/treydock))
- Add registration\_allowed to keycloak\_realm [\#160](https://github.com/treydock/puppet-module-keycloak/pull/160) ([anlambert](https://github.com/anlambert))
- Have realms and identity providers auto require their configured flows [\#159](https://github.com/treydock/puppet-module-keycloak/pull/159) ([treydock](https://github.com/treydock))

### Fixed

- Realm can not depend on flow that depends on realm [\#162](https://github.com/treydock/puppet-module-keycloak/pull/162) ([treydock](https://github.com/treydock))

## [v6.17.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.17.0) (2020-09-24)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.16.0...v6.17.0)

### Added

- Improved unit and acceptance tests for recent changes [\#158](https://github.com/treydock/puppet-module-keycloak/pull/158) ([treydock](https://github.com/treydock))
- add bruteForceProtected [\#157](https://github.com/treydock/puppet-module-keycloak/pull/157) ([aba-rechsteiner](https://github.com/aba-rechsteiner))
- add trustEmail [\#156](https://github.com/treydock/puppet-module-keycloak/pull/156) ([aba-rechsteiner](https://github.com/aba-rechsteiner))
- add keycloak-oidc providerid and other new parameters [\#155](https://github.com/treydock/puppet-module-keycloak/pull/155) ([aba-rechsteiner](https://github.com/aba-rechsteiner))

## [v6.16.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.16.0) (2020-08-21)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.15.0...v6.16.0)

### Added

- Added a parameter to control if the managed user is a system user [\#152](https://github.com/treydock/puppet-module-keycloak/pull/152) ([ZloeSabo](https://github.com/ZloeSabo))

## [v6.15.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.15.0) (2020-08-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.14.0...v6.15.0)

### Added

- add resources [\#151](https://github.com/treydock/puppet-module-keycloak/pull/151) ([aba-rechsteiner](https://github.com/aba-rechsteiner))

## [v6.14.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.14.0) (2020-08-11)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.13.1...v6.14.0)

### Added

- add proxy-address-forwarding for https-listener [\#149](https://github.com/treydock/puppet-module-keycloak/pull/149) ([aba-rechsteiner](https://github.com/aba-rechsteiner))
- Add support for required actions [\#148](https://github.com/treydock/puppet-module-keycloak/pull/148) ([ZloeSabo](https://github.com/ZloeSabo))

## [v6.13.1](https://github.com/treydock/puppet-module-keycloak/tree/v6.13.1) (2020-08-03)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.13.0...v6.13.1)

### Fixed

- Explicitly specifies what user to use with the admin generation script [\#146](https://github.com/treydock/puppet-module-keycloak/pull/146) ([ZloeSabo](https://github.com/ZloeSabo))

## [v6.13.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.13.0) (2020-07-07)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.12.0...v6.13.0)

### Added

- Concat custom code fragment to config.cli [\#145](https://github.com/treydock/puppet-module-keycloak/pull/145) ([danifr](https://github.com/danifr))
- Update usage of deprecated function postgresql\_password [\#143](https://github.com/treydock/puppet-module-keycloak/pull/143) ([Karlinde](https://github.com/Karlinde))

## [v6.12.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.12.0) (2020-07-02)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.11.0...v6.12.0)

### Added

- Emit warning if configured theme does not exist [\#140](https://github.com/treydock/puppet-module-keycloak/pull/140) ([treydock](https://github.com/treydock))
- Add support for JGroups JDBC\_PING mode in clustered mode [\#139](https://github.com/treydock/puppet-module-keycloak/pull/139) ([danifr](https://github.com/danifr))

### UNCATEGORIZED PRS; GO LABEL THEM

- Remove outdated line in class documentation [\#137](https://github.com/treydock/puppet-module-keycloak/pull/137) ([danifr](https://github.com/danifr))

## [v6.11.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.11.0) (2020-05-22)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.10.0...v6.11.0)

### Added

- PDK update and test Keycloak 10.0.1 [\#133](https://github.com/treydock/puppet-module-keycloak/pull/133) ([treydock](https://github.com/treydock))

### UNCATEGORIZED PRS; GO LABEL THEM

- Add support for defining smtpServer from realms [\#131](https://github.com/treydock/puppet-module-keycloak/pull/131) ([mattock](https://github.com/mattock))
- Allow enabling/disabling client authorization services [\#127](https://github.com/treydock/puppet-module-keycloak/pull/127) ([mattock](https://github.com/mattock))

## [v6.10.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.10.0) (2020-03-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.9.0...v6.10.0)

### Added

- Add support and tests for Keycloak 9.0.0 [\#128](https://github.com/treydock/puppet-module-keycloak/pull/128) ([treydock](https://github.com/treydock))

## [v6.9.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.9.0) (2020-02-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.8.0...v6.9.0)

### Added

- Add access\_token\_lifespan to keycloak\_realm [\#126](https://github.com/treydock/puppet-module-keycloak/pull/126) ([treydock](https://github.com/treydock))

## [v6.8.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.8.0) (2020-02-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.7.0...v6.8.0)

### Added

- Add access\_code\_lifespan to keycloak\_realm [\#125](https://github.com/treydock/puppet-module-keycloak/pull/125) ([treydock](https://github.com/treydock))

## [v6.7.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.7.0) (2020-02-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.6.0...v6.7.0)

### Added

- Add sso\_session\_idle\_timeout and sso\_session\_max\_lifespan to keycloak\_realm [\#124](https://github.com/treydock/puppet-module-keycloak/pull/124) ([treydock](https://github.com/treydock))

## [v6.6.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.6.0) (2020-02-10)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.5.0...v6.6.0)

### Added

- Support oidc-audience-mapper protocol mapper [\#122](https://github.com/treydock/puppet-module-keycloak/pull/122) ([treydock](https://github.com/treydock))

## [v6.5.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.5.0) (2020-02-07)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.4.1...v6.5.0)

### Added

- Add root\_url and base\_url properties to keycloak\_client [\#121](https://github.com/treydock/puppet-module-keycloak/pull/121) ([treydock](https://github.com/treydock))
- Allow enabling/disabling realm internationalization [\#119](https://github.com/treydock/puppet-module-keycloak/pull/119) ([mattock](https://github.com/mattock))

## [v6.4.1](https://github.com/treydock/puppet-module-keycloak/tree/v6.4.1) (2020-02-06)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.4.0...v6.4.1)

### Fixed

- type/keycloak\_api: Set install\_dir default on /opt/keycloak [\#120](https://github.com/treydock/puppet-module-keycloak/pull/120) ([tcassaert](https://github.com/tcassaert))

## [v6.4.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.4.0) (2020-02-03)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.3.0...v6.4.0)

### Added

- Support oidc-group-membership-mapper protocol mapper type [\#118](https://github.com/treydock/puppet-module-keycloak/pull/118) ([treydock](https://github.com/treydock))

## [v6.3.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.3.0) (2020-01-16)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.2.0...v6.3.0)

### Added

- Add client\_auth\_method property to keycloak\_identity\_provider [\#117](https://github.com/treydock/puppet-module-keycloak/pull/117) ([treydock](https://github.com/treydock))

## [v6.2.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.2.0) (2020-01-09)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.1.0...v6.2.0)

### Added

- Support managing authentication flows [\#115](https://github.com/treydock/puppet-module-keycloak/pull/115) ([treydock](https://github.com/treydock))
- Support disabling the user cache [\#114](https://github.com/treydock/puppet-module-keycloak/pull/114) ([treydock](https://github.com/treydock))
- Support Keycloak SPI deployments [\#113](https://github.com/treydock/puppet-module-keycloak/pull/113) ([treydock](https://github.com/treydock))
- Add content\_security\_policy to keycloak\_realm [\#112](https://github.com/treydock/puppet-module-keycloak/pull/112) ([treydock](https://github.com/treydock))
- Improve handling of realm flow assignment to avoid errors [\#111](https://github.com/treydock/puppet-module-keycloak/pull/111) ([treydock](https://github.com/treydock))
- Support managing realm flow properties [\#110](https://github.com/treydock/puppet-module-keycloak/pull/110) ([treydock](https://github.com/treydock))

### Fixed

- Fix bug in flow parsing [\#116](https://github.com/treydock/puppet-module-keycloak/pull/116) ([treydock](https://github.com/treydock))

## [v6.1.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.1.0) (2019-12-31)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v6.0.0...v6.1.0)

### Added

- Add support for access.token.lifespan client attribute [\#109](https://github.com/treydock/puppet-module-keycloak/pull/109) ([mattock](https://github.com/mattock))
- Add two new realm properties [\#108](https://github.com/treydock/puppet-module-keycloak/pull/108) ([mattock](https://github.com/mattock))

## [v6.0.0](https://github.com/treydock/puppet-module-keycloak/tree/v6.0.0) (2019-12-18)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.10.0...v6.0.0)

### Changed

- Change default Keycloak version to 8.0.1 [\#106](https://github.com/treydock/puppet-module-keycloak/pull/106) ([treydock](https://github.com/treydock))
- Change JAVA\_OPTS behavior for Keycloak [\#105](https://github.com/treydock/puppet-module-keycloak/pull/105) ([treydock](https://github.com/treydock))
- Change how install\_dir is defined, default behavior remains the same [\#90](https://github.com/treydock/puppet-module-keycloak/pull/90) ([treydock](https://github.com/treydock))

## [v5.10.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.10.0) (2019-12-10)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.9.0...v5.10.0)

### Added

- Allow defining supported locales for the realm [\#103](https://github.com/treydock/puppet-module-keycloak/pull/103) ([mattock](https://github.com/mattock))

## [v5.9.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.9.0) (2019-12-09)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.8.0...v5.9.0)

### Added

- Support Debian 10 [\#102](https://github.com/treydock/puppet-module-keycloak/pull/102) ([treydock](https://github.com/treydock))

## [v5.8.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.8.0) (2019-12-06)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.7.0...v5.8.0)

### Added

- Test against Keycloak 8.0.1 [\#100](https://github.com/treydock/puppet-module-keycloak/pull/100) ([treydock](https://github.com/treydock))
- Add option to enable tech preview features [\#99](https://github.com/treydock/puppet-module-keycloak/pull/99) ([treydock](https://github.com/treydock))
- Add login\_theme property to keycloak\_client [\#98](https://github.com/treydock/puppet-module-keycloak/pull/98) ([treydock](https://github.com/treydock))
- Add support for more client switches [\#96](https://github.com/treydock/puppet-module-keycloak/pull/96) ([mattock](https://github.com/mattock))
- Add option to enable tech preview features [\#95](https://github.com/treydock/puppet-module-keycloak/pull/95) ([danifr](https://github.com/danifr))

### Fixed

- Fix config.cli to be able to change datasource values [\#101](https://github.com/treydock/puppet-module-keycloak/pull/101) ([treydock](https://github.com/treydock))

## [v5.7.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.7.0) (2019-10-29)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.6.0...v5.7.0)

### Added

- Make JDBC xa-datasource-class name configurable [\#93](https://github.com/treydock/puppet-module-keycloak/pull/93) ([danifr](https://github.com/danifr))

## [v5.6.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.6.0) (2019-10-10)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.5.0...v5.6.0)

### Added

- Support EL8 [\#91](https://github.com/treydock/puppet-module-keycloak/pull/91) ([treydock](https://github.com/treydock))

## [v5.5.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.5.0) (2019-09-26)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.4.0...v5.5.0)

### Added

- Allow managing Keycloak installation from outside this module [\#87](https://github.com/treydock/puppet-module-keycloak/pull/87) ([mattock](https://github.com/mattock))
- Enable passing extra options to Keycloak in the systemd unit file [\#86](https://github.com/treydock/puppet-module-keycloak/pull/86) ([mattock](https://github.com/mattock))
- Enable defining bind address for the Keycloak systemd service [\#85](https://github.com/treydock/puppet-module-keycloak/pull/85) ([mattock](https://github.com/mattock))

## [v5.4.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.4.0) (2019-09-05)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.3.2...v5.4.0)

### Added

- Support Ubuntu 18.04 [\#84](https://github.com/treydock/puppet-module-keycloak/pull/84) ([treydock](https://github.com/treydock))
- Vagrant: add Ubuntu 1804 box [\#83](https://github.com/treydock/puppet-module-keycloak/pull/83) ([mattock](https://github.com/mattock))

## [v5.3.2](https://github.com/treydock/puppet-module-keycloak/tree/v5.3.2) (2019-09-03)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.3.1...v5.3.2)

### Fixed

- Fix acceptance tests for SAML attribute name format [\#82](https://github.com/treydock/puppet-module-keycloak/pull/82) ([treydock](https://github.com/treydock))

## [v5.3.1](https://github.com/treydock/puppet-module-keycloak/tree/v5.3.1) (2019-09-03)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.3.0...v5.3.1)

### Fixed

- Fix URI mapping for protocol mappers [\#81](https://github.com/treydock/puppet-module-keycloak/pull/81) ([treydock](https://github.com/treydock))

## [v5.3.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.3.0) (2019-08-30)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.2.0...v5.3.0)

### Added

- Fix \#78. Add clustered mode support [\#79](https://github.com/treydock/puppet-module-keycloak/pull/79) ([danifr](https://github.com/danifr))

## [v5.2.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.2.0) (2019-08-29)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.1.0...v5.2.0)

### Added

- Test against Keycloak 7.0.0 [\#77](https://github.com/treydock/puppet-module-keycloak/pull/77) ([treydock](https://github.com/treydock))

## [v5.1.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.1.0) (2019-08-28)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.0.1...v5.1.0)

### Added

- Support merging Hiera defined resources [\#75](https://github.com/treydock/puppet-module-keycloak/pull/75) ([treydock](https://github.com/treydock))

## [v5.0.1](https://github.com/treydock/puppet-module-keycloak/tree/v5.0.1) (2019-08-27)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v5.0.0...v5.0.1)

### Fixed

- Should be no default for keycloak\_client\_scope consent\_screen\_text property [\#74](https://github.com/treydock/puppet-module-keycloak/pull/74) ([treydock](https://github.com/treydock))

## [v5.0.0](https://github.com/treydock/puppet-module-keycloak/tree/v5.0.0) (2019-08-27)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v4.2.0...v5.0.0)

### Changed

- Remove keycloak::client\_template [\#71](https://github.com/treydock/puppet-module-keycloak/pull/71) ([treydock](https://github.com/treydock))

## [v4.2.0](https://github.com/treydock/puppet-module-keycloak/tree/v4.2.0) (2019-08-27)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v4.1.1...v4.2.0)

### Added

- Support group-ldap-mapper and role-ldap-mapper [\#73](https://github.com/treydock/puppet-module-keycloak/pull/73) ([treydock](https://github.com/treydock))
- Support saml-javascript-mapper for keycloak\_client\_protocol\_mapper [\#72](https://github.com/treydock/puppet-module-keycloak/pull/72) ([treydock](https://github.com/treydock))

## [v4.1.1](https://github.com/treydock/puppet-module-keycloak/tree/v4.1.1) (2019-08-26)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v4.1.0...v4.1.1)

### Fixed

- Fix default for keycloak\_identity\_provider prompt [\#70](https://github.com/treydock/puppet-module-keycloak/pull/70) ([treydock](https://github.com/treydock))

## [v4.1.0](https://github.com/treydock/puppet-module-keycloak/tree/v4.1.0) (2019-08-26)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v4.0.0...v4.1.0)

### Added

- Add clients parameter [\#69](https://github.com/treydock/puppet-module-keycloak/pull/69) ([treydock](https://github.com/treydock))
- Simplify how keycloak\_client\_protocol\_mapper and keycloak\_protcol\_mapper are queried during prefetch [\#68](https://github.com/treydock/puppet-module-keycloak/pull/68) ([treydock](https://github.com/treydock))
- Support managing protocl mapper saml-javascript-mapper [\#67](https://github.com/treydock/puppet-module-keycloak/pull/67) ([treydock](https://github.com/treydock))
- Update module dependency version requirements [\#66](https://github.com/treydock/puppet-module-keycloak/pull/66) ([treydock](https://github.com/treydock))
- Use iteration and added parameters to define resources [\#65](https://github.com/treydock/puppet-module-keycloak/pull/65) ([treydock](https://github.com/treydock))
- Add keycloak\_identity\_provider type [\#64](https://github.com/treydock/puppet-module-keycloak/pull/64) ([treydock](https://github.com/treydock))

## [v4.0.0](https://github.com/treydock/puppet-module-keycloak/tree/v4.0.0) (2019-06-12)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v3.8.0...v4.0.0)

### Changed

- Simplify and consolidate datasource parameters [\#63](https://github.com/treydock/puppet-module-keycloak/pull/63) ([treydock](https://github.com/treydock))
- Set default Keycloak version to 6.0.1 [\#61](https://github.com/treydock/puppet-module-keycloak/pull/61) ([treydock](https://github.com/treydock))

### Added

- Use hiera v5 module data [\#62](https://github.com/treydock/puppet-module-keycloak/pull/62) ([treydock](https://github.com/treydock))

## [v3.8.0](https://github.com/treydock/puppet-module-keycloak/tree/v3.8.0) (2019-05-23)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.7.0...v3.8.0)

### Added

- Use PDK [\#58](https://github.com/treydock/puppet-module-keycloak/pull/58) ([treydock](https://github.com/treydock))

## [3.7.0](https://github.com/treydock/puppet-module-keycloak/tree/3.7.0) (2019-05-20)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.6.1...3.7.0)

### Added

- Expand postgresql support to behave more like mysql support, simplified a bit [\#60](https://github.com/treydock/puppet-module-keycloak/pull/60) ([treydock](https://github.com/treydock))
- Postgresql support [\#59](https://github.com/treydock/puppet-module-keycloak/pull/59) ([verrydtj](https://github.com/verrydtj))

## [3.6.1](https://github.com/treydock/puppet-module-keycloak/tree/3.6.1) (2019-05-13)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.6.0...3.6.1)

### Fixed

- Fix handling of events config during updates [\#56](https://github.com/treydock/puppet-module-keycloak/pull/56) ([treydock](https://github.com/treydock))

## [3.6.0](https://github.com/treydock/puppet-module-keycloak/tree/3.6.0) (2019-05-06)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.5.0...3.6.0)

### Added

- Support managing realm's events config [\#55](https://github.com/treydock/puppet-module-keycloak/pull/55) ([treydock](https://github.com/treydock))
- Test against Keycloak 6 [\#54](https://github.com/treydock/puppet-module-keycloak/pull/54) ([treydock](https://github.com/treydock))

## [3.5.0](https://github.com/treydock/puppet-module-keycloak/tree/3.5.0) (2019-04-09)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.4.0...3.5.0)

### Added

- manage user support [\#53](https://github.com/treydock/puppet-module-keycloak/pull/53) ([cborisa](https://github.com/cborisa))

## [3.4.0](https://github.com/treydock/puppet-module-keycloak/tree/3.4.0) (2019-02-25)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.3.0...3.4.0)

### Added

- JAVA\_OPTS via systemd unit Environment variable [\#51](https://github.com/treydock/puppet-module-keycloak/pull/51) ([danifr](https://github.com/danifr))
- Add option for service environment file [\#50](https://github.com/treydock/puppet-module-keycloak/pull/50) ([asieraguado](https://github.com/asieraguado))

## [3.3.0](https://github.com/treydock/puppet-module-keycloak/tree/3.3.0) (2019-01-28)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.2.0...3.3.0)

### Added

- Better ID handling [\#47](https://github.com/treydock/puppet-module-keycloak/pull/47) ([treydock](https://github.com/treydock))
- Test against Keycloak 4.8.1.Final and document version handling and upgrade [\#43](https://github.com/treydock/puppet-module-keycloak/pull/43) ([treydock](https://github.com/treydock))
- Add enabled property to keycloak\_ldap\_user\_provider [\#41](https://github.com/treydock/puppet-module-keycloak/pull/41) ([treydock](https://github.com/treydock))

### Fixed

- Fix keycloak\_ldap\_mapper id handling and write\_only property [\#46](https://github.com/treydock/puppet-module-keycloak/pull/46) ([treydock](https://github.com/treydock))
- Fix PuppetX usage for keycloak\_ldap\_mapper [\#45](https://github.com/treydock/puppet-module-keycloak/pull/45) ([treydock](https://github.com/treydock))

## [3.2.0](https://github.com/treydock/puppet-module-keycloak/tree/3.2.0) (2018-12-21)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.1.0...3.2.0)

### Added

- Support SSSD User Provider [\#42](https://github.com/treydock/puppet-module-keycloak/pull/42) ([treydock](https://github.com/treydock))

## [3.1.0](https://github.com/treydock/puppet-module-keycloak/tree/3.1.0) (2018-12-13)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.0.0...3.1.0)

### Added

- Bump dependency ranges for stdlib and mysql [\#40](https://github.com/treydock/puppet-module-keycloak/pull/40) ([treydock](https://github.com/treydock))
- Support Puppet 6 and drop support for Puppet 4 [\#39](https://github.com/treydock/puppet-module-keycloak/pull/39) ([treydock](https://github.com/treydock))
- Use beaker 4.x [\#37](https://github.com/treydock/puppet-module-keycloak/pull/37) ([treydock](https://github.com/treydock))

### Fixed

- Fix keycloak\_ldap\_user\_provider bind\_credential property to be idempotent [\#38](https://github.com/treydock/puppet-module-keycloak/pull/38) ([treydock](https://github.com/treydock))

## [3.0.0](https://github.com/treydock/puppet-module-keycloak/tree/3.0.0) (2018-08-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.7.1...3.0.0)

### Added

- Update module dependency version ranges [\#35](https://github.com/treydock/puppet-module-keycloak/pull/35) ([treydock](https://github.com/treydock))

## [2.7.1](https://github.com/treydock/puppet-module-keycloak/tree/2.7.1) (2018-08-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.7.0...2.7.1)

### Fixed

- Update reference [\#36](https://github.com/treydock/puppet-module-keycloak/pull/36) ([treydock](https://github.com/treydock))

## [2.7.0](https://github.com/treydock/puppet-module-keycloak/tree/2.7.0) (2018-08-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.6.0...2.7.0)

### Added

- Oracle support [\#33](https://github.com/treydock/puppet-module-keycloak/pull/33) ([cborisa](https://github.com/cborisa))

## [2.6.0](https://github.com/treydock/puppet-module-keycloak/tree/2.6.0) (2018-07-20)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.5.0...2.6.0)

### Added

- Use puppet-strings for documentation [\#30](https://github.com/treydock/puppet-module-keycloak/pull/30) ([treydock](https://github.com/treydock))
- Add search\_scope and custom\_user\_search\_filter properties to keycloak\_ldap\_user\_provider type [\#29](https://github.com/treydock/puppet-module-keycloak/pull/29) ([treydock](https://github.com/treydock))
- Explicitly define all type properties [\#27](https://github.com/treydock/puppet-module-keycloak/pull/27) ([treydock](https://github.com/treydock))
- Improve acceptance tests [\#26](https://github.com/treydock/puppet-module-keycloak/pull/26) ([treydock](https://github.com/treydock))

### Fixed

- Fix for keycloak\_protocol\_mapper type property and type unit test improvements [\#28](https://github.com/treydock/puppet-module-keycloak/pull/28) ([treydock](https://github.com/treydock))

## [2.5.0](https://github.com/treydock/puppet-module-keycloak/tree/2.5.0) (2018-07-18)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.4.0...2.5.0)

### Added

- Support setting auth\_type=simple related properties for keycloak\_ldap\_user\_provider type [\#24](https://github.com/treydock/puppet-module-keycloak/pull/24) ([treydock](https://github.com/treydock))

## [2.4.0](https://github.com/treydock/puppet-module-keycloak/tree/2.4.0) (2018-06-04)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.3.1...2.4.0)

### Added

- Add keycloak\_api configuration type [\#22](https://github.com/treydock/puppet-module-keycloak/pull/22) ([treydock](https://github.com/treydock))

## [2.3.1](https://github.com/treydock/puppet-module-keycloak/tree/2.3.1) (2018-03-10)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.3.0...2.3.1)

### Fixed

- Fix title patterns that use procs are not supported [\#21](https://github.com/treydock/puppet-module-keycloak/pull/21) ([alexjfisher](https://github.com/alexjfisher))

## [2.3.0](https://github.com/treydock/puppet-module-keycloak/tree/2.3.0) (2018-03-08)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.2.1...2.3.0)

### Added

- Allow keycloak\_protocol\_mapper attribute\_nameformat to be simpler values [\#18](https://github.com/treydock/puppet-module-keycloak/pull/18) ([treydock](https://github.com/treydock))
- Add SAML username protocol mapper to keycloak::client\_template [\#17](https://github.com/treydock/puppet-module-keycloak/pull/17) ([treydock](https://github.com/treydock))
- Support SAML role list protocol mapper [\#16](https://github.com/treydock/puppet-module-keycloak/pull/16) ([treydock](https://github.com/treydock))
- Add SAML support to keycloak\_protocol\_mapper and keycloak::client\_template [\#15](https://github.com/treydock/puppet-module-keycloak/pull/15) ([treydock](https://github.com/treydock))

### Fixed

- Fix SAML username protocol mapper to match keycloak code [\#19](https://github.com/treydock/puppet-module-keycloak/pull/19) ([treydock](https://github.com/treydock))

## [2.2.1](https://github.com/treydock/puppet-module-keycloak/tree/2.2.1) (2018-02-27)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.2.0...2.2.1)

### Fixed

- Do not show diff of files that may contain passwords [\#14](https://github.com/treydock/puppet-module-keycloak/pull/14) ([treydock](https://github.com/treydock))

## [2.2.0](https://github.com/treydock/puppet-module-keycloak/tree/2.2.0) (2018-02-26)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.1.0...2.2.0)

### Added

- Make management of the MySQL database optional [\#13](https://github.com/treydock/puppet-module-keycloak/pull/13) ([treydock](https://github.com/treydock))

## [2.1.0](https://github.com/treydock/puppet-module-keycloak/tree/2.1.0) (2018-02-22)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.0.1...2.1.0)

### Added

- Increase minimum java dependency to 2.2.0 to to support Debian 9. Update unit tests to test all supported OSes [\#12](https://github.com/treydock/puppet-module-keycloak/pull/12) ([treydock](https://github.com/treydock))
- Symlink instead of copy mysql connector. puppetlabs/mysql 5 compatibility [\#11](https://github.com/treydock/puppet-module-keycloak/pull/11) ([NITEMAN](https://github.com/NITEMAN))
- Add support for http port configuration [\#9](https://github.com/treydock/puppet-module-keycloak/pull/9) ([NITEMAN](https://github.com/NITEMAN))
- Add Debian 9 support [\#8](https://github.com/treydock/puppet-module-keycloak/pull/8) ([NITEMAN](https://github.com/NITEMAN))

### Fixed

- Fix ownership of install dir [\#10](https://github.com/treydock/puppet-module-keycloak/pull/10) ([NITEMAN](https://github.com/NITEMAN))

## [2.0.1](https://github.com/treydock/puppet-module-keycloak/tree/2.0.1) (2017-12-18)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/2.0.0...2.0.1)

### Fixed

- Fix configuration order when proxy\_https is true [\#7](https://github.com/treydock/puppet-module-keycloak/pull/7) ([treydock](https://github.com/treydock))

## [2.0.0](https://github.com/treydock/puppet-module-keycloak/tree/2.0.0) (2017-12-11)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/1.0.0...2.0.0)

### Changed

- BREAKING: Remove deprecated defined types [\#6](https://github.com/treydock/puppet-module-keycloak/pull/6) ([treydock](https://github.com/treydock))
- BREAKING: Set default version to 3.4.1.Final [\#4](https://github.com/treydock/puppet-module-keycloak/pull/4) ([treydock](https://github.com/treydock))
- BREAKING: Drop Puppet 3 support [\#3](https://github.com/treydock/puppet-module-keycloak/pull/3) ([treydock](https://github.com/treydock))

### Added

- Add always\_read\_value\_from\_ldap property to keycloak\_ldap\_mapper [\#5](https://github.com/treydock/puppet-module-keycloak/pull/5) ([treydock](https://github.com/treydock))

## [1.0.0](https://github.com/treydock/puppet-module-keycloak/tree/1.0.0) (2017-09-05)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/0.0.1...1.0.0)

### Added

- New types [\#1](https://github.com/treydock/puppet-module-keycloak/pull/1) ([treydock](https://github.com/treydock))

## [0.0.1](https://github.com/treydock/puppet-module-keycloak/tree/0.0.1) (2017-08-11)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/7af5fcb032534265eac261fc7a723cb7b27007f4...0.0.1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
