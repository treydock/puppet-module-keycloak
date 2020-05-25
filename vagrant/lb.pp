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

haproxy::balancermember { 'dc':
  listening_service => 'kc',
  server_names      => 'dc.local',
  ipaddresses       => '192.168.168.253',
  ports             => '8080',
  options           => 'cookie DC check',
}

haproxy::balancermember { 'hc':
  listening_service => 'kc',
  server_names      => 'hc.local',
  ipaddresses       => '192.168.168.252',
  ports             => '8080',
  options           => 'cookie HC check',
}


