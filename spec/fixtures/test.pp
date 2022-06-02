include mysql::server
class { 'keycloak':
  db        => 'mariadb',
  hostname  => 'localhost',
  proxy     => 'edge',
  http_host => '127.0.0.1',
  http_port => 9090,
  configs   => {
    'hostname-port'         => 8080,
    'hostname-strict-https' => false,
  },
}
class { 'apache':
  default_vhost => false,
}
apache::vhost { 'localhost':
  servername          => 'localhost',
  port                => '8080',
  ssl                 => false,
  manage_docroot      => false,
  docroot             => '/var/www/html',
  proxy_preserve_host => true,
  proxy_add_headers   => true,
  proxy_pass          => [
    {'path' => '/', 'url' => 'http://localhost:9090/'}
  ],
  request_headers     => [
    'set X-Forwarded-Proto "http"',
    'set X-Forwarded-Port "8080"'
  ],
  #headers => [
  #  'always unset X-Frame-Options',
  #],
}