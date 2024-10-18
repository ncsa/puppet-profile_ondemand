# @summary Configure the navigation bar for OOD
#
# @param include_default
#   Whether to include the default navbar items. Defaults to true
#
# @param navbar_items
#   Array of items to put in the navbar (left side)
#
# @param helpbar_items
#   Array of items to put in the helpbar (right side)
#
class profile_ondemand::navbar (
  Boolean $include_default = true,
  Optional[Array[Hash]] $navbar_items = undef,
  Optional[Array[Hash]] $helpbar_items = undef,
) {
  if $include_default {
    $_content = {
      nav_bar  => join([
          'apps',
          'files',
          'jobs',
          'clusters',
          'interactive apps',
          $navbar_items,
          'sessions',
      ]),
      help_bar => join([
          $helpbar_items,
          'develop',
          'help',
          'user',
          'logout',
      ]),
    }
  } else {
    if ! $navbar_items and ! $helpbar_items {
      warning('Open OnDemand has an empty navigation bar!')
    }
    $_content = {
      nav_bar  => $navbar_items,
      help_bar => $helpbar_items,
    }
  }

  file { '/etc/ood/config/ondemand.d/custom-navbar.yml':
    ensure  => 'file',
    mode    => '0644',
    content => join([
        '# File managed by Puppet - DO NOT EDIT',
        to_yaml($_content),
        '',
    ], '\n'),
  }
}
