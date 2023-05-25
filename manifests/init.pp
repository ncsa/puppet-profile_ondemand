# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include profile_ondemand
class profile_ondemand (
  String $nodejs_version,
  String $ruby_version,
  Hash $crons,
) {
  include apache::mod::rewrite
  include apache::mod::env
  include apache::mod::alias
  include apache::mod::authn_core
  include apache::mod::authz_user
  include apache::mod::authnz_ldap
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

  $crons.each | $k, $v | {
    cron { $k: * => $v }
  }
}
