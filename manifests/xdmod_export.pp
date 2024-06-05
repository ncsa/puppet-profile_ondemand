# @summary Configure the xdmod export script
#
# @param enable_xdmod_export
#   Whether to set up the script on the server. Defaults to false
#
# @param token
#   Token used to authenticate with the log server
#
class profile_ondemand::xdmod_export (
  Boolean $enable_xdmod_export = false,
  Optional[String] $token,
) {

  if $enable_xdmod_export {
    assert_type(String[1], $token)

    user { 'xdmod-ondemand-export':
      shell => '/bin/false',
      managehome => true,
      password => '!DISABLED',
    }

    exec { '/usr/bin/python3 -m venv /home/xdmod-ondemand-export/venv':
      user => 'xdmod-ondemand-export',
      creates => '/home/xdmod-ondemand-export/venv',
      require => Package['httpd'],
    }
    -> exec { 'python3 -m pip install xdmod-ondemand-export':
      path => '/home/xdmod-ondemand-export/venv/bin:/usr/bin:/usr/sbin:/bin',
      user => 'xdmod-ondemand-export',
      creates => '/home/xdmod-ondemand-export/venv/bin/xdmod-ondemand-export',
    }
    -> exec { 'setfacl -m u:xdmod-ondemand-export:r-x /etc/httpd/logs':
      path => '/usr/bin:/usr/sbin:/bin',
      unless => 'getfacl /etc/httpd/logs/ | grep xdmod-ondemand-export',
    }
    -> exec { 'setfacl -m u:xdmod-ondemand-export:r-- /etc/httpd/logs/*':
      path => '/usr/bin:/usr/sbin:/bin',
      unless => 'getfacl /etc/httpd/logs/* | grep xdmod-ondemand-export',
    }
    -> exec { 'setfacl -dm u:xdmod-ondemand-export:r-- /etc/httpd/logs':
      path => '/usr/bin:/usr/sbin:/bin',
      unless => 'getfacl -d /etc/httpd/logs/ | grep xdmod-ondemand-export',
    }

    file { '/home/xdmod-ondemand-export/conf.ini':
      ensure  => 'file',
      require => User['xdmod-ondemand-export'],
      owner => 'xdmod-ondemand-export',
      group => 'xdmod-ondemand-export',
      mode => '0400',
      content => file('profile_ondemand/xdmod_export_conf.ini'),
    }

    file { '/home/xdmod-ondemand-export/.token':
      ensure  => 'file',
      replace => false,
      require => User['xdmod-ondemand-export'],
      owner => 'xdmod-ondemand-export',
      group => 'xdmod-ondemand-export',
      mode => '0600',
      content => $token,
    }

    file { '/home/xdmod-ondemand-export/last-run.json':
      ensure  => 'present',
      require => User['xdmod-ondemand-export'],
      owner => 'xdmod-ondemand-export',
      group => 'xdmod-ondemand-export',
      mode => '0600',
    }

    cron { 'xdmod-ondemand-export':
      command => "su -c '/home/xdmod-ondemand-export/venv/bin/xdmod-ondemand-export' -s /bin/bash xdmod-ondemand-export",
      hour => fqdn_rand(24),
      minute => fqdn_rand(60),
    }

  }
}
