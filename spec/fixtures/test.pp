include mysql::server
class { 'keycloak':
  datasource_driver => 'mysql',
}
