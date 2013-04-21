
class cluster_pkg {

  user { 'mysql':
    ensure => present,
  }

  package { 'libaio1':
    ensure => present
  }

  exec { 'extract-cluster':
    path    => ['/bin', '/usr/bin'],
    command => 'tar -C /usr/local -zxvf /puppet/mysql-cluster-gpl-7.2.12-linux2.6-x86_64.tar.gz',
    unless  => 'file /usr/local/mysql 2>/dev/null'
  }

  file { '/usr/local/mysql':
    ensure => link,
    target => 'mysql-cluster-gpl-7.2.12-linux2.6-x86_64'
  }

  file { '/etc/bash.bashrc':
    ensure => present,
    source => '/puppet/bash.bashrc',
    owner  => 'root',
    group  => 'root',
  }
}

class cluster {
  include cluster_pkg

  exec { './scripts/mysql_install_db':
    path      => ['/bin', '/usr/bin', '/usr/local/mysql'],
    cwd       => '/usr/local/mysql/',
    logoutput => true,
    command   => './scripts/mysql_install_db --user=mysql 1>/tmp/m.out 2>&1',
    require   => File['/usr/local/mysql'],
    user      => 'root',
    tries     => 3, # definitely ghetto
  } ->

  exec { 'chown_1':
    path    => ['/bin', '/usr/bin'],
    cwd     => '/usr/local/mysql',
    command => 'chown -R root .'
  } ->

  exec { 'chown_2':
    path    => ['/bin', '/usr/bin'],
    cwd     => '/usr/local/mysql',
    command => 'chown -R mysql data'
  } ->

  exec { 'chown_3':
    path    => ['/bin', '/usr/bin'],
    cwd     => '/usr/local/mysql',
    command => 'chgrp -R mysql .'
  } ->

  file { '/etc/init.d/mysql':
    ensure => present,
    source => '/usr/local/mysql/support-files/mysql.server',
    mode   => '0744',
    owner  => 'root',
  } ->

  file { '/var/log/mysql':
    ensure => directory,
    owner  => 'root',
  } ->

  exec { 'update-rc.d':
    path    => ['/bin', '/usr/sbin'],
    command => 'update-rc.d mysql defaults',
    user    => 'root',
  } ->

  file { '/etc/my.cnf':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => '/puppet/my.cnf',
  } ->

  exec { 'ndbd' :
    path    => ['/usr/local/mysql/bin'],
    command => 'ndbd',
  } ->

  exec { 'service mysql start':
    path    => ['/bin', '/usr/bin'],
    command => 'service mysql start',
  } ->

  mysqldb { "myapp":
    user        => "myappuser",
    password    => "5uper5secret",
  }

}

node 'node1' {
  include cluster
}

node 'node2' {
  include cluster
}

node 'mgmt' {
  include cluster_pkg

  file { '/var/lib/mysql-cluster':
    ensure  => directory,
    recurse => true,
  } ->

  file { '/var/lib/mysql-cluster/config.ini':
    ensure => present,
    source => '/puppet/config.ini'
  } ->

  exec { 'ndb_mgmd' :
    path    => ['/usr/local/mysql/bin'],
    command => 'ndb_mgmd -f /var/lib/mysql-cluster/config.ini --configdir /var/lib/mysql-cluster',
  }
}

define mysqldb( $user, $password ) {
  exec { "create-${name}-db":
    unless  => "mysql -u${user} -p${password} ${name}",
    path    => ['/bin', '/usr/bin', '/usr/local/mysql/bin'],
    command => "mysql -uroot -e \"create database ${name}; grant all on ${name}.* to ${user}@'%' identified by '${password}';\"",
    require => Exec["service mysql start"],
  }
}

/* vim:set sw=2 ts=2: */
