class { '::postgresql::globals':
  manage_package_repo => $manage_package_repo,
  version             => $postgresql_version,
}

class { '::postgresql::server':
  listen_addresses => $postgresql_listen_address,
  require          => Class['::postgresql::globals']
}

::postgresql::server::role { $db_username:
  password_hash    => postgresql_password($db_username, $db_password),
  connection_limit => $db_connection_limit,
  require          => Class['::postgresql::server']
}

::postgresql::server::database_grant { "Grant all to ${db_username}":
  privilege => 'ALL',
  db        => $db_database,
  role      => $db_username,
}

::postgresql::server::db { $db_database:
  user     => $db_username,
  password => postgresql_password($db_username, $db_password),
}

postgresql::server::pg_hba_rule { 'Allow Keycloak instances network access to the database':
  description => 'Open up PostgreSQL for access from 192.168.0.0/24',
  type        => 'host',
  database    => $db_username,
  user        => $db_password,
  address     => '192.168.0.0/24',
  auth_method => 'md5',
  require     => Class['::postgresql::server']
}
