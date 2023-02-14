# @summary Manage MySQL DB
#
# @api private
class keycloak::db::mysql {
  assert_private()

  if $keycloak::manage_db_server {
    contain mysql::server
  }

  if $keycloak::manage_db {
    mysql::db { $keycloak::db_url_database:
      user     => $keycloak::db_username,
      password => $keycloak::db_password,
      host     => $keycloak::db_url_host,
      grant    => 'ALL',
      charset  => $keycloak::db_charset,
      collate  => $keycloak::db_collate,
    }
  }
}
