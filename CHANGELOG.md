## treydock-keycloak changelog

Release notes for the treydock-keycloak module.

------------------------------------------

#### 1.0.0 - 2017-09-05

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

#### 0.0.1 - 2017-08-11

Initial release
