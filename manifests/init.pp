# @summary Main class for profile_ondemand
#
# @param custom_certificates
#   Optionally provide custom parameters for certificate(s) to
#   be created. If this is not provided a cert will be created
#   using the FQDN of the host.
#
# @param nodejs_version
#   The Node.js version to use for dependency. Leave unset/null
#   to NOT enable the DNF module nodejs:<nodejs_version>.
#
# @param ruby_version
#   The Ruby version to use for dependency. Leave unset/null
#   to NOT enable the DNF module nodejs:<nodejs_version>.
#
# @param crons
#   Hash of cron jobs to set up
#
# @param enable_xdmod_export
#   Whether to set up xdmod_export for ACCESS metrics
#
# @param enable_dynamic_widgets
#   Whether to enable dynamic widgets in OOD forms
#   See https://osc.github.io/ood-documentation/latest/reference/files/ondemand-d-ymls.html#bc-dynamic-js
#
# @example
#   include profile_ondemand
class profile_ondemand (
  Hash             $custom_certificates,
  Optional[String] $nodejs_version,
  Optional[String] $ruby_version,
  Hash             $crons,
  Boolean          $enable_xdmod_export = false,
  Boolean          $enable_dynamic_widgets = true,
) {
  include apache::mod::rewrite
  include apache::mod::env
  include apache::mod::alias
  include apache::mod::authn_core
  include apache::mod::authz_user
  include letsencrypt
  include openondemand
  include stdlib

  include profile_ondemand::navbar

  if $enable_xdmod_export {
    include profile_ondemand::xdmod_export
  }

  if $enable_dynamic_widgets {
    file { '/etc/ood/config/ondemand.d/dynamic-widgets.yml':
      ensure  => 'file',
      content => 'bc_dynamic_js: true',
    }
  }

  # make management of nodejs "package" (actually DNF module) optional
  if ( $nodejs_version) {
    package { 'nodejs':
      ensure      => $nodejs_version,
      enable_only => true,
      provider    => 'dnfmodule',
      before      => Class['openondemand'],
    }
  }

  # make management of ruby "package" (actually DNF module) optional
  if ( $ruby_version) {
    package { 'ruby':
      ensure      => $ruby_version,
      enable_only => true,
      provider    => 'dnfmodule',
      before      => Class['openondemand'],
    }
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

  file { '/opt/ood/custom/ood-ssh.sh':
    ensure  => 'file',
    mode    => '0755',
    content => file('profile_ondemand/ood-ssh.sh'),
  }

  $crons.each | $k, $v | {
    cron { $k: * => $v }
  }

  if !empty($custom_certificates) {
    $custom_certificates.each |$certificate, $properties| {
      letsencrypt::certonly { $certificate: * => $properties }
    }
  } else {
    letsencrypt::certonly { $facts['networking']['fqdn']:
      plugin  => 'standalone',
      require => [
        Package['httpd'],
        Class['openondemand'],
      ],
    }
  }
}
