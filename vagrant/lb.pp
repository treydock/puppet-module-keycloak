notify { 'Installing Load Balancer': }

include ::haproxy

haproxy::listen { 'kc':
  collect_exported => false,
  ipaddress        => $facts['networking']['interfaces']['eth1']['ip'],
  mode             => 'http',
  ports            => '80',
  options          => {
    'option'       => [
      'tcplog',
      'forwardfor',
      'http-keep-alive'
    ],
    'balance'      => 'roundrobin',
    'cookie'       => 'SRVNAME insert',
    'http-request' => 'set-header X-Forwarded-Port %[dst_port]',
  },
}

haproxy::balancermember { 'master':
  listening_service => 'kc',
  server_names      => 'master.local',
  ipaddresses       => '192.168.168.253',
  ports             => '8080',
  options           => 'cookie DC check',
}

haproxy::balancermember { 'slave':
  listening_service => 'kc',
  server_names      => 'slave.local',
  ipaddresses       => '192.168.168.252',
  ports             => '8080',
  options           => 'cookie HC check',
}


