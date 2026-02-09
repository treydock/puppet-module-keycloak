# @summary Manage postgres DB
#
# @api private
class keycloak::db::postgres {
  assert_private()

  if $keycloak::manage_db_server {
    contain postgresql::server
  }

  if $keycloak::manage_db {
    postgresql::server::db { $keycloak::db_url_database:
      user     => $keycloak::db_username,
      owner    => $keycloak::db_username,
      password => postgresql::postgresql_password($keycloak::db_username, $keycloak::db_password),
      encoding => $keycloak::db_encoding,
    }
  }
}
