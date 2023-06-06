# @summary Main class for profile_ondemand
#
# @param nodejs_version
#   The Node.js version to use for dependency
#
# @param ruby_version
#   The Ruby version to use for dependency
#
# @param crons
#   Hash of cron jobs to set up
#
# @param favorite_paths
#   Array of paths to be added as favorites for the Files app
#
# @example
#   include profile_ondemand
class profile_ondemand (
  String $nodejs_version,
  String $ruby_version,
  Hash $crons,
  Array $favorite_paths,
) {
  include apache::mod::rewrite
  include apache::mod::env
  include apache::mod::alias
  include apache::mod::authn_core
  include apache::mod::authz_user
  include openondemand

  package { 'nodejs':
    ensure      => $nodejs_version,
    enable_only => true,
    provider    => 'dnfmodule',
    before      => Class['openondemand'],
  }

  package { 'ruby':
    ensure      => $ruby_version,
    enable_only => true,
    provider    => 'dnfmodule',
    before      => Class['openondemand'],
  }

  file { '/etc/ood/config/ood-portal.conf':
    mode => '0600',
  }

  file { '/opt/ood/custom':
    ensure => 'directory',
    mode   => '0755',
  }

  file { '/opt/ood/custom/ood-gridmap.py':
    ensure  => 'file',
    mode    => '0755',
    content => file('profile_ondemand/ood-gridmap.py'),
  }

  exec { 'mkdir -p /etc/ood/config/apps/dashboard/initializers':
    creates => '/etc/ood/config/apps/dashboard/initializers',
    path    => ['/usr/bin', '/usr/sbin'],
    # Need this to execute after the openondemand module creates and cleans out the directory
    require => File['/etc/ood/config/apps'],
  }

  file { '/etc/ood/config/apps/dashboard/initializers/ood.rb':
    ensure  => 'file',
    mode    => '0755',
    content => epp('profile_ondemand/apps/dashboard/initializers/ood.rb.epp'),
    require => Exec['mkdir -p /etc/ood/config/apps/dashboard/initializers'],
  }

  $crons.each | $k, $v | {
    cron { $k: * => $v }
  }
}
