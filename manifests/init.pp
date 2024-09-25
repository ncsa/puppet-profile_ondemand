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
# @param enable_xdmod_export
#   Whether to set up xdmod_export for ACCESS metrics
#
# @param navbar_items
#   Hash of custom items to add to the navbar
#   If left undefined, use the default navbar
#
# @example
#   include profile_ondemand
class profile_ondemand (
  String $nodejs_version,
  String $ruby_version,
  Hash $crons,
  Boolean $enable_xdmod_export = false,
  Hash $navbar_items = undef,
) {
  include apache::mod::rewrite
  include apache::mod::env
  include apache::mod::alias
  include apache::mod::authn_core
  include apache::mod::authz_user
  include letsencrypt
  include openondemand

  if $enable_xdmod_export {
    include profile_ondemand::xdmod_export
  }

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
    ensure  => 'directory',
    mode    => '0755',
    require => Class['openondemand'],
  }

  file { '/opt/ood/custom/ood-gridmap.py':
    ensure  => 'file',
    mode    => '0755',
    content => file('profile_ondemand/ood-gridmap.py'),
  }

  $crons.each | $k, $v | {
    cron { $k: * => $v }
  }

  if $navbar_items {
    file { '/etc/ood/config/ondemand.d/custom-navbar.yml':
      ensure  => 'file',
      mode    => '0644',
      content => template('profile_ondemand/custom-navbar.yml.epp'),
    }
  }

  letsencrypt::certonly { $facts['networking']['fqdn']:
    plugin  => 'standalone',
    require => [
      Package['httpd'],
      Class['openondemand'],
    ],
  }
}
