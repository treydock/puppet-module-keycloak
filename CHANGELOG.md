# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

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

- Expand postgresql support to behave more like mysql support, simplified a bit [\#60](https://github.com/treydock/puppet-module-keycloak/pull/60) ([treydock](https://github.com/treydock))
- Use PDK [\#58](https://github.com/treydock/puppet-module-keycloak/pull/58) ([treydock](https://github.com/treydock))

## [3.7.0](https://github.com/treydock/puppet-module-keycloak/tree/3.7.0) (2019-05-20)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.6.1...3.7.0)

### Added

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

### Fixed

- Fix keycloak\_ldap\_mapper id handling and write\_only property [\#46](https://github.com/treydock/puppet-module-keycloak/pull/46) ([treydock](https://github.com/treydock))
- Fix PuppetX usage for keycloak\_ldap\_mapper [\#45](https://github.com/treydock/puppet-module-keycloak/pull/45) ([treydock](https://github.com/treydock))

## [3.2.0](https://github.com/treydock/puppet-module-keycloak/tree/3.2.0) (2018-12-21)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/3.1.0...3.2.0)

### Added

- Support SSSD User Provider [\#42](https://github.com/treydock/puppet-module-keycloak/pull/42) ([treydock](https://github.com/treydock))
- Add enabled property to keycloak\_ldap\_user\_provider [\#41](https://github.com/treydock/puppet-module-keycloak/pull/41) ([treydock](https://github.com/treydock))

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



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
