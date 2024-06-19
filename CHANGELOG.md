# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v11.2.0](https://github.com/treydock/puppet-module-keycloak/tree/v11.2.0) (2024-06-19)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v11.1.1...v11.2.0)

### Added

- Implement realm otp, webauthn, webauthn passwordless and bruteforce properties [\#312](https://github.com/treydock/puppet-module-keycloak/pull/312) ([TuningYourCode](https://github.com/TuningYourCode))

## [v11.1.1](https://github.com/treydock/puppet-module-keycloak/tree/v11.1.1) (2024-05-03)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v11.1.0...v11.1.1)

### Fixed

- Allow mapped\_group\_attributes to be removed by defaulting to absent [\#311](https://github.com/treydock/puppet-module-keycloak/pull/311) ([treydock](https://github.com/treydock))

## [v11.1.0](https://github.com/treydock/puppet-module-keycloak/tree/v11.1.0) (2024-04-19)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v11.0.2...v11.1.0)

### Added

- Support Keycloak 24 [\#310](https://github.com/treydock/puppet-module-keycloak/pull/310) ([treydock](https://github.com/treydock))

## [v11.0.2](https://github.com/treydock/puppet-module-keycloak/tree/v11.0.2) (2024-04-19)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v11.0.1...v11.0.2)

### Added

- allow absolute path for package\_url parameter [\#305](https://github.com/treydock/puppet-module-keycloak/pull/305) ([trefzer](https://github.com/trefzer))

### Fixed

- Bugfix: remove double declaration of "log-level" [\#308](https://github.com/treydock/puppet-module-keycloak/pull/308) ([sircubbi](https://github.com/sircubbi))
- Fix \#306 - Retrieve parentId by realm name [\#307](https://github.com/treydock/puppet-module-keycloak/pull/307) ([TuningYourCode](https://github.com/TuningYourCode))

## [v11.0.1](https://github.com/treydock/puppet-module-keycloak/tree/v11.0.1) (2023-09-22)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v11.0.0...v11.0.1)

### Fixed

- Do not purge truststore.jks by default [\#303](https://github.com/treydock/puppet-module-keycloak/pull/303) ([treydock](https://github.com/treydock))

## [v11.0.0](https://github.com/treydock/puppet-module-keycloak/tree/v11.0.0) (2023-07-19)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v10.2.0...v11.0.0)

### Changed

- Drop Puppet 6, add Puppet 8 support, drop Ubuntu 18.04 [\#298](https://github.com/treydock/puppet-module-keycloak/pull/298) ([treydock](https://github.com/treydock))
- Support Keycloak 22, Drop EL7 and Debian 10 [\#297](https://github.com/treydock/puppet-module-keycloak/pull/297) ([treydock](https://github.com/treydock))
- Default java\_declare\_method to class for Debian and Ubuntu [\#295](https://github.com/treydock/puppet-module-keycloak/pull/295) ([treydock](https://github.com/treydock))

### Added

- Add keycloak::partial\_import resource [\#301](https://github.com/treydock/puppet-module-keycloak/pull/301) ([treydock](https://github.com/treydock))
- Add properties to keycloak\_client\_protocol\_mapper [\#300](https://github.com/treydock/puppet-module-keycloak/pull/300) ([treydock](https://github.com/treydock))
- Add cache\_policy property to keycloal\_ldap\_user\_provider [\#296](https://github.com/treydock/puppet-module-keycloak/pull/296) ([treydock](https://github.com/treydock))
- Add default\_locale property to keycloak\_realm [\#294](https://github.com/treydock/puppet-module-keycloak/pull/294) ([treydock](https://github.com/treydock))
- Set JAVA\_HOME environment variable for Keycloak service [\#293](https://github.com/treydock/puppet-module-keycloak/pull/293) ([treydock](https://github.com/treydock))

### Fixed

- Do not reassign $hostname variable when http\_enabled=false [\#299](https://github.com/treydock/puppet-module-keycloak/pull/299) ([treydock](https://github.com/treydock))

## [v10.2.0](https://github.com/treydock/puppet-module-keycloak/tree/v10.2.0) (2023-06-16)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v10.1.0...v10.2.0)

### Added

- Allow newer dependency versions [\#289](https://github.com/treydock/puppet-module-keycloak/pull/289) ([saz](https://github.com/saz))

## [v10.1.0](https://github.com/treydock/puppet-module-keycloak/tree/v10.1.0) (2023-04-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v10.0.1...v10.1.0)

### Added

- Add db\_encoding parameter for postgres [\#287](https://github.com/treydock/puppet-module-keycloak/pull/287) ([treydock](https://github.com/treydock))

## [v10.0.1](https://github.com/treydock/puppet-module-keycloak/tree/v10.0.1) (2023-04-10)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v10.0.0...v10.0.1)

### Fixed

- Avoid errors when prefetching realms [\#286](https://github.com/treydock/puppet-module-keycloak/pull/286) ([treydock](https://github.com/treydock))

## [v10.0.0](https://github.com/treydock/puppet-module-keycloak/tree/v10.0.0) (2023-04-05)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.4.0...v10.0.0)

### Changed

- Default to Keycloak 21.0.1 and Use OpenJDK 17 where possible [\#283](https://github.com/treydock/puppet-module-keycloak/pull/283) ([treydock](https://github.com/treydock))

## [v9.4.0](https://github.com/treydock/puppet-module-keycloak/tree/v9.4.0) (2023-03-22)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.3.4...v9.4.0)

### Added

- Support Ubuntu 22.04 [\#282](https://github.com/treydock/puppet-module-keycloak/pull/282) ([treydock](https://github.com/treydock))
- Support Keycloak 21.x [\#281](https://github.com/treydock/puppet-module-keycloak/pull/281) ([treydock](https://github.com/treydock))

## [v9.3.4](https://github.com/treydock/puppet-module-keycloak/tree/v9.3.4) (2023-03-20)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.3.3...v9.3.4)

### Fixed

- Improve logging of connection validator [\#280](https://github.com/treydock/puppet-module-keycloak/pull/280) ([treydock](https://github.com/treydock))

## [v9.3.3](https://github.com/treydock/puppet-module-keycloak/tree/v9.3.3) (2023-03-09)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.3.2...v9.3.3)

### Fixed

- Use http\_relative\_path with keycloak\_conn\_validator [\#278](https://github.com/treydock/puppet-module-keycloak/pull/278) ([treydock](https://github.com/treydock))

## [v9.3.2](https://github.com/treydock/puppet-module-keycloak/tree/v9.3.2) (2023-02-15)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.3.1...v9.3.2)

### Fixed

- Allow hostname setting to not use default value [\#275](https://github.com/treydock/puppet-module-keycloak/pull/275) ([treydock](https://github.com/treydock))

## [v9.3.1](https://github.com/treydock/puppet-module-keycloak/tree/v9.3.1) (2023-01-04)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.3.0...v9.3.1)

### Fixed

- Allow keycloak.v2 theme to be used [\#273](https://github.com/treydock/puppet-module-keycloak/pull/273) ([treydock](https://github.com/treydock))

## [v9.3.0](https://github.com/treydock/puppet-module-keycloak/tree/v9.3.0) (2022-12-21)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.2.0...v9.3.0)

### Added

- Switch the Duo SPI used for testing and documentation [\#271](https://github.com/treydock/puppet-module-keycloak/pull/271) ([treydock](https://github.com/treydock))

## [v9.2.0](https://github.com/treydock/puppet-module-keycloak/tree/v9.2.0) (2022-12-19)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.1.0...v9.2.0)

### Added

- Allow to configure LDAP kerberos through the module [\#269](https://github.com/treydock/puppet-module-keycloak/pull/269) ([PopiBrossard](https://github.com/PopiBrossard))

## [v9.1.0](https://github.com/treydock/puppet-module-keycloak/tree/v9.1.0) (2022-12-02)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.0.1...v9.1.0)

### Added

- Update allowed configs and allow extra configs [\#268](https://github.com/treydock/puppet-module-keycloak/pull/268) ([treydock](https://github.com/treydock))

## [v9.0.1](https://github.com/treydock/puppet-module-keycloak/tree/v9.0.1) (2022-11-22)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v9.0.0...v9.0.1)

### Fixed

- Wrap kcadm-wrapper arguments in quotes [\#266](https://github.com/treydock/puppet-module-keycloak/pull/266) ([treydock](https://github.com/treydock))

## [v9.0.0](https://github.com/treydock/puppet-module-keycloak/tree/v9.0.0) (2022-11-01)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v8.5.0...v9.0.0)

### Changed

- BREAKING: Default to Keycloak 19 [\#262](https://github.com/treydock/puppet-module-keycloak/pull/262) ([treydock](https://github.com/treydock))

## [v8.5.0](https://github.com/treydock/puppet-module-keycloak/tree/v8.5.0) (2022-10-31)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v8.4.0...v8.5.0)

### Added

- Add db\_collate param [\#263](https://github.com/treydock/puppet-module-keycloak/pull/263) ([NITEMAN](https://github.com/NITEMAN))

## [v8.4.0](https://github.com/treydock/puppet-module-keycloak/tree/v8.4.0) (2022-10-26)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v8.3.0...v8.4.0)

### Added

- Add duplicate\_emails\_allowed to keycloak\_realm [\#260](https://github.com/treydock/puppet-module-keycloak/pull/260) ([treydock](https://github.com/treydock))

## [v8.3.0](https://github.com/treydock/puppet-module-keycloak/tree/v8.3.0) (2022-10-18)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v8.2.0...v8.3.0)

### Added

- Add support for centralized logging via Gelf [\#257](https://github.com/treydock/puppet-module-keycloak/pull/257) ([nblock](https://github.com/nblock))
- Support EL9 [\#250](https://github.com/treydock/puppet-module-keycloak/pull/250) ([treydock](https://github.com/treydock))

### Fixed

- Remove --auto-build from start command on Keycloak 19+ [\#259](https://github.com/treydock/puppet-module-keycloak/pull/259) ([treydock](https://github.com/treydock))

## [v8.2.0](https://github.com/treydock/puppet-module-keycloak/tree/v8.2.0) (2022-10-10)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v8.1.0...v8.2.0)

### Added

- Support MySQL module 13.x [\#256](https://github.com/treydock/puppet-module-keycloak/pull/256) ([treydock](https://github.com/treydock))
- Use http-relative-path for wrapper\_server [\#254](https://github.com/treydock/puppet-module-keycloak/pull/254) ([nblock](https://github.com/nblock))

### Fixed

- Use a regular string for cache-config-file option [\#255](https://github.com/treydock/puppet-module-keycloak/pull/255) ([nblock](https://github.com/nblock))

## [v8.1.0](https://github.com/treydock/puppet-module-keycloak/tree/v8.1.0) (2022-07-13)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v8.0.0...v8.1.0)

### Added

- Add support for syncResgistrations [\#252](https://github.com/treydock/puppet-module-keycloak/pull/252) ([NITEMAN](https://github.com/NITEMAN))

## [v8.0.0](https://github.com/treydock/puppet-module-keycloak/tree/v8.0.0) (2022-06-24)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.19.0...v8.0.0)

### Changed

- Major rewrite to support Keycloak 18+ using Quarkus \(see README for breaking changes\) [\#247](https://github.com/treydock/puppet-module-keycloak/pull/247) ([treydock](https://github.com/treydock))
- BREAKING: Change how id is set for keycloak\_ldap\_user\_provider \(See README\) [\#76](https://github.com/treydock/puppet-module-keycloak/pull/76) ([treydock](https://github.com/treydock))

### Fixed

- Fix realm and other resources to handle names with spaces [\#249](https://github.com/treydock/puppet-module-keycloak/pull/249) ([treydock](https://github.com/treydock))

## [v7.19.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.19.0) (2022-05-13)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.18.0...v7.19.0)

### Added

- Allow changing auth URL via auth\_url\_path parameter [\#245](https://github.com/treydock/puppet-module-keycloak/pull/245) ([treydock](https://github.com/treydock))

### Fixed

- fix profile.properties file path in domain mode [\#244](https://github.com/treydock/puppet-module-keycloak/pull/244) ([surcouf](https://github.com/surcouf))

## [v7.18.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.18.0) (2022-04-29)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.17.0...v7.18.0)

### Added

- Allow postgresql \< 9.0.0 [\#242](https://github.com/treydock/puppet-module-keycloak/pull/242) ([saz](https://github.com/saz))

## [v7.17.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.17.0) (2022-04-25)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.16.0...v7.17.0)

### Added

- Support Debian 11 [\#241](https://github.com/treydock/puppet-module-keycloak/pull/241) ([vilhelmprytz](https://github.com/vilhelmprytz))

## [v7.16.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.16.0) (2022-04-04)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.15.0...v7.16.0)

### Added

- Support Keycloak 16 [\#239](https://github.com/treydock/puppet-module-keycloak/pull/239) ([treydock](https://github.com/treydock))

## [v7.15.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.15.0) (2022-04-04)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.14.0...v7.15.0)

### Added

- New saml attrs [\#238](https://github.com/treydock/puppet-module-keycloak/pull/238) ([wolfaba](https://github.com/wolfaba))

## [v7.14.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.14.0) (2022-03-14)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.13.0...v7.14.0)

### Added

- add backchannel logout url attribute [\#237](https://github.com/treydock/puppet-module-keycloak/pull/237) ([wolfaba](https://github.com/wolfaba))

## [v7.13.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.13.0) (2022-02-10)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.12.2...v7.13.0)

### Added

- Realm role mapping support [\#233](https://github.com/treydock/puppet-module-keycloak/pull/233) ([mattock](https://github.com/mattock))

## [v7.12.2](https://github.com/treydock/puppet-module-keycloak/tree/v7.12.2) (2022-02-08)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.12.1...v7.12.2)

### Fixed

- Fix authorization services data corruption on unrelated client changes [\#236](https://github.com/treydock/puppet-module-keycloak/pull/236) ([mattock](https://github.com/mattock))

## [v7.12.1](https://github.com/treydock/puppet-module-keycloak/tree/v7.12.1) (2022-01-18)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.12.0...v7.12.1)

### Fixed

- Quota datasource username and password [\#235](https://github.com/treydock/puppet-module-keycloak/pull/235) ([treydock](https://github.com/treydock))
- Fix issues with install\_base /opt/keycloak [\#232](https://github.com/treydock/puppet-module-keycloak/pull/232) ([dmaes](https://github.com/dmaes))

## [v7.12.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.12.0) (2021-11-24)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.11.1...v7.12.0)

### Added

- Add Realm properties and allow custom properties [\#228](https://github.com/treydock/puppet-module-keycloak/pull/228) ([treydock](https://github.com/treydock))

## [v7.11.1](https://github.com/treydock/puppet-module-keycloak/tree/v7.11.1) (2021-11-24)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.11.0...v7.11.1)

### Fixed

- Further fix to set description on keycloak\_flow when not top\_level flow [\#227](https://github.com/treydock/puppet-module-keycloak/pull/227) ([treydock](https://github.com/treydock))
- Fix to set description on keycloak\_flow when not top\_level flow [\#226](https://github.com/treydock/puppet-module-keycloak/pull/226) ([treydock](https://github.com/treydock))

## [v7.11.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.11.0) (2021-11-05)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.10.0...v7.11.0)

### Added

- Replace CentOS 8 support with Rocky 8 [\#221](https://github.com/treydock/puppet-module-keycloak/pull/221) ([treydock](https://github.com/treydock))
- Support stdlib 8.x, mysql 12.x and use puppet/systemd [\#220](https://github.com/treydock/puppet-module-keycloak/pull/220) ([treydock](https://github.com/treydock))
- Add id parameter to keycloak::freeipa\_user\_provider [\#219](https://github.com/treydock/puppet-module-keycloak/pull/219) ([treydock](https://github.com/treydock))

## [v7.10.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.10.0) (2021-09-22)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.9.1...v7.10.0)

### Added

- Add feature `user_managed_access_allowed` property [\#211](https://github.com/treydock/puppet-module-keycloak/pull/211) ([rdcuzins](https://github.com/rdcuzins))

### Fixed

- Fix and tune mangement interface definitions for both master and slave [\#217](https://github.com/treydock/puppet-module-keycloak/pull/217) ([kibahop](https://github.com/kibahop))

## [v7.9.1](https://github.com/treydock/puppet-module-keycloak/tree/v7.9.1) (2021-09-16)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.9.0...v7.9.1)

### Fixed

- set keycloak\_server in keycloak\_conn\_validator from 'localhost' to $service\_bind\_address [\#216](https://github.com/treydock/puppet-module-keycloak/pull/216) ([hugendudel](https://github.com/hugendudel))

## [v7.9.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.9.0) (2021-09-08)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.8.0...v7.9.0)

### Added

- Remove Scientific Linux from metadata.json, still supported [\#213](https://github.com/treydock/puppet-module-keycloak/pull/213) ([treydock](https://github.com/treydock))
- add saml-user-attribute-mapper support [\#212](https://github.com/treydock/puppet-module-keycloak/pull/212) ([aba-rechsteiner](https://github.com/aba-rechsteiner))

### Fixed

- Fix centos/7 in Vagrant failing [\#210](https://github.com/treydock/puppet-module-keycloak/pull/210) ([rdcuzins](https://github.com/rdcuzins))
- Fix invalid module dependency versions [\#209](https://github.com/treydock/puppet-module-keycloak/pull/209) ([rdcuzins](https://github.com/rdcuzins))

## [v7.8.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.8.0) (2021-09-01)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.7.1...v7.8.0)

### Added

- Added support for bearer-only configuration of keycloak\_client [\#207](https://github.com/treydock/puppet-module-keycloak/pull/207) ([ghost](https://github.com/ghost))

## [v7.7.1](https://github.com/treydock/puppet-module-keycloak/tree/v7.7.1) (2021-08-23)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.7.0...v7.7.1)

### Fixed

- Fix assigning management interfaces to logical interfaces in domain mode [\#206](https://github.com/treydock/puppet-module-keycloak/pull/206) ([kibahop](https://github.com/kibahop))

## [v7.7.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.7.0) (2021-08-16)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.6.0...v7.7.0)

### Added

- Support Keycloak 15.x [\#204](https://github.com/treydock/puppet-module-keycloak/pull/204) ([treydock](https://github.com/treydock))

## [v7.6.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.6.0) (2021-08-13)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.5.1...v7.6.0)

### Added

- Add extra configurations to keycloak realm [\#203](https://github.com/treydock/puppet-module-keycloak/pull/203) ([qboileau](https://github.com/qboileau))

## [v7.5.1](https://github.com/treydock/puppet-module-keycloak/tree/v7.5.1) (2021-08-03)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.5.0...v7.5.1)

### Fixed

- Ensure flow execution will add config if not added on create [\#201](https://github.com/treydock/puppet-module-keycloak/pull/201) ([treydock](https://github.com/treydock))

## [v7.5.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.5.0) (2021-07-12)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.4.1...v7.5.0)

### Added

- Update dependency version ranges [\#200](https://github.com/treydock/puppet-module-keycloak/pull/200) ([treydock](https://github.com/treydock))
- Support Keycloak 14 [\#199](https://github.com/treydock/puppet-module-keycloak/pull/199) ([treydock](https://github.com/treydock))
- Fix Ubuntu acceptance tests [\#198](https://github.com/treydock/puppet-module-keycloak/pull/198) ([treydock](https://github.com/treydock))

## [v7.4.1](https://github.com/treydock/puppet-module-keycloak/tree/v7.4.1) (2021-07-10)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.4.0...v7.4.1)

### Fixed

- Remove prefixes from socket-binding-groups [\#197](https://github.com/treydock/puppet-module-keycloak/pull/197) ([kibahop](https://github.com/kibahop))

## [v7.4.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.4.0) (2021-06-03)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.3.0...v7.4.0)

### Added

- Allow flows and flow executions to depend on SPI deployments [\#196](https://github.com/treydock/puppet-module-keycloak/pull/196) ([treydock](https://github.com/treydock))

## [v7.3.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.3.0) (2021-06-02)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.2.2...v7.3.0)

### Added

- Support Keycloak 13.x [\#195](https://github.com/treydock/puppet-module-keycloak/pull/195) ([treydock](https://github.com/treydock))
- Vagrant: install puppetlabs-postgresql [\#193](https://github.com/treydock/puppet-module-keycloak/pull/193) ([mattock](https://github.com/mattock))

## [v7.2.2](https://github.com/treydock/puppet-module-keycloak/tree/v7.2.2) (2021-04-23)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.2.1...v7.2.2)

### Fixed

- Domain mode sockets [\#192](https://github.com/treydock/puppet-module-keycloak/pull/192) ([kibahop](https://github.com/kibahop))

## [v7.2.1](https://github.com/treydock/puppet-module-keycloak/tree/v7.2.1) (2021-04-17)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.2.0...v7.2.1)

### Fixed

- Fix keycloak\_client to be able to update the secret [\#191](https://github.com/treydock/puppet-module-keycloak/pull/191) ([treydock](https://github.com/treydock))

## [v7.2.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.2.0) (2021-03-26)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.1.0...v7.2.0)

### Added

- Add support for logging to syslog [\#190](https://github.com/treydock/puppet-module-keycloak/pull/190) ([kibahop](https://github.com/kibahop))

## [v7.1.0](https://github.com/treydock/puppet-module-keycloak/tree/v7.1.0) (2021-03-25)

[Full Changelog](https://github.com/treydock/puppet-module-keycloak/compare/v7.0.0...v7.1.0)

### Added

- FreeIPA/LDAP provider related regression fixes [\#189](https://github.com/treydock/puppet-module-keycloak/pull/189) ([mattock](https://github.com/mattock))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
