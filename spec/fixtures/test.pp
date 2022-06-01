include mysql::server
class { 'keycloak':
  db => 'mysql',
}
