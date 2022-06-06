# @summary Manage MySQL DB
#
# @api private
class keycloak::db::mariadb {
  assert_private()

  contain 'keycloak::db::mysql'
}
