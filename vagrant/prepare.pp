notify { 'Preparing for setup': }

$tools = [ 'emacs-nox', 'tcpdump', 'strace', 'nmap', 'screen', 'net-tools' ]

package { $tools:
  ensure  => 'installed',
}

package { 'r10k':
  ensure   => 'present',
  provider => 'puppet_gem',
}

exec { 'Update modules':
  logoutput => true,
  command   => "r10k puppetfile install --puppetfile ${::basedir}/vagrant/Puppetfile --verbose --moduledir /etc/puppetlabs/code/environments/production/modules", # lint:ignore:140chars
  timeout   => 600,
  path      => ['/bin','/usr/bin','/opt/puppetlabs/bin','/opt/puppetlabs/puppet/bin'],
}

package { 'git':
  ensure => 'latest',
}

file { '/etc/puppetlabs/code/environments/production/modules/keycloak':
  ensure => 'link',
  target => "${::basedir}",
}
