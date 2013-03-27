class phabricator (
  $path,
  $hostname,
  $mysql_rootpass = '',
  $owner = 'root',
  $group = 'root',
) {
  # Install mysql and php modules
  
  Package { ensure => 'installed' }

  include 'mysql'
  
  $phpmodules = ['php5',
                 'php5-mysql',
                 'php5-gd',
                 'php5-dev',
                 'php5-curl',
                 'php-apc',
                 'php5-cli']

  package { $phpmodules: }

  package { 'dpkg-dev': }

  # Get phabricator git repositories

  file { $path: ensure => directory, }

  $libpdir = "${path}/libphutil"

  $arcdir = "${path}/arcanist"

  $phabdir = "${path}/phabricator"

  include 'git'

  Git::Repo {
    require => File[$path],
    owner   => $owner,
    group   => $group,
  }

  git::repo { $libpdir:
    clonesource => "git://github.com/facebook/libphutil.git",
  }
  
  git::repo { $arcdir:
    clonesource => "git://github.com/facebook/arcanist.git",
  }

  git::repo { $phabdir:
    clonesource => "git://github.com/facebook/phabricator.git",
  }

  # Configure apache vhost

  include 'apache'

  include 'apache::mod::php'

  apache::mod { 'rewrite': }

  apache::vhost { $hostname:
    port     => '80',
    docroot  => "${phabdir}/webroot",
    template => 'phabricator/apache-vhost-default.conf.erb',
    require  => Git::Repo[$phabdir],
  }

  # Set default configuration
  # We use a template configuration file with the mysql root password

  $confdir = "${phabdir}/conf/custom"

  $conffile = 'default.conf.php' # Phabricator configuration file

  file { $confdir:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    require => Git::Repo[$phabdir],
  }

  file { $conffile:
    ensure  => present,
    path    => "${confdir}/${conffile}",
    content => template("phabricator/${conffile}.erb"),
    owner   => $owner,
    group   => $group,
    require => File[$confdir],
  }

  file { 'ENVIRONMENT':
    ensure  => present,
    path    => "${phabdir}/conf/local/ENVIRONMENT",
    content => "custom/default",
    require => [
      Package['httpd'],
      File[$conffile],
    ],
    notify  => Service['httpd'],
  }
}
