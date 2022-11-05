##############################################################
#
#  install
#
##############################################################458
#
# @summary Install subclass
#
# @param manage_nodejs_package
#   Should we manage nodejs package?
# @param nodejs_debug_package_ensure
#   Ensure value for debug package
# @param nodejs_package_name
#   Package name for nodejs
# @param npm_package_ensure
#   Dist npm package state
# @param gentoo_use_flags
#   Gentoo use_package use_flags
# @param npmrc_config
#   Configuration to place in .npmrc file
# @param nodejs_debug_package_name
#   Package name for nodejs debug package
# @param nodejs_dev_package_ensure
#   Ensure value for dev libraries package
# @param nodejs_dev_package_name
#   Package name for nodejs dev package
# @param nodejs_package_ensure
#   Dist nodejs package state
# @param npmrc_auth
#   Value for '_auth' key in .npmrc 
# @param package_provider
#   Package provider override, defaults to 'chocolatey' on Windows
# @param npm_package_name
#   Package name for npm package
#

#
class nodejs::install (
  Boolean $manage_nodejs_package,
  String $nodejs_debug_package_ensure,
  String $nodejs_package_name,
  String $npm_package_ensure,
  Array $gentoo_use_flags = [],
  Hash $npmrc_config = {},
  Optional[String] $nodejs_debug_package_name = undef,
  Optional[String] $nodejs_dev_package_ensure = undef,
  Optional[String] $nodejs_dev_package_name = undef,
  Optional[String] $nodejs_package_ensure = undef,
  Optional[String] $npmrc_auth = undef,
  Optional[String] $package_provider = undef,
  Optional[Variant[Boolean, String]] $npm_package_name = undef,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Gentoo
  if $facts['os']['name'] == 'Gentoo' and $manage_nodejs_package {
    package_use { $nodejs_package_name:
      ensure => present,
      target => 'nodejs-flags',
      use    => $gentoo_use_flags, #gentoo_use_flags is only used here
      before => Package[$nodejs_package_name],
    }
  }

  Package { provider => $package_provider }

  # nodejs
  if $manage_nodejs_package {
    package { $nodejs_package_name:
      ensure => $nodejs_package_ensure,
      tag    => 'nodesource_repo',
    }
  }

  # nodejs-development
  if $manage_nodejs_package and $nodejs_dev_package_name {
    package { $nodejs_dev_package_name:
      ensure => $nodejs_dev_package_ensure,
      tag    => 'nodesource_repo',
    }
  }

  # nodejs-debug
  if $nodejs_debug_package_name {
    package { $nodejs_debug_package_name:
      ensure => $nodejs_debug_package_ensure,
      tag    => 'nodesource_repo',
    }
  }

  # npm
  if ($npm_package_name) and ($npm_package_name != false) {
    package { $npm_package_name:
      ensure => $npm_package_ensure,
      tag    => 'nodesource_repo',
    }
  }

  if $facts['os']['name'] != 'Windows' {
    file { 'root_npmrc':
      ensure  => 'file',
      path    => "${facts['root_home']}/.npmrc",
      content => template('nodejs/npmrc.erb'),
      owner   => 'root',
      group   => '0',
      mode    => '0600',
    }
  }
}
