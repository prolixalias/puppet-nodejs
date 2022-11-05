##############################################################
#
#   nodejs: See README.md for documentation
#
##############################################################458
#
# @summary Install and configure node.js
#
# @param manage_package_repo
#   Should we manage nodesource repo?
# @param repo_enable_src
#   Is the source code repository enabled?
# @param nodejs_debug_package_ensure
#   Ensure value for debug package
# @param nodejs_dev_package_ensure
#   Ensure value for dev libraries package
# @param nodejs_package_ensure
#   Dist nodejs package state
# @param nodejs_package_name
#   Package name for nodejs
# @param npm_path
#   Absolute path to npm binary
# @param repo_ensure
#   Is the nodesource repo enabled?
# @param repo_priority
#   Yum repo 'priority' value for nodesource repo
# @param repo_url_suffix
#   Nodesource repo suffix, essentially yhe version of nodejs
# @param gentoo_use_flags
#   Gentoo use_package use_flags
# @param manage_nodejs_package
#   Should we manage nodejs package?
# @param npmrc_config
#   Configuration to place in .npmrc file
# @param cmd_exe_path
#   Absolute path to cmd (windows)
# @param nodejs_debug_package_name
#   Package name for nodejs debug package
# @param nodejs_dev_package_name
#   Package name for nodejs dev package
# @param npmrc_auth
#   Value for '_auth' key in .npmrc 
# @param package_provider
#   Package provider override, defaults to 'chocolatey' on Windows
# @param repo_class
#   Parent subclass to call for managing repositories 
# @param repo_pin
#   Apt pinning
# @param repo_proxy
#   FQDN of proxy
# @param repo_proxy_password
#   Passowrd to access proxy
# @param repo_proxy_username
#   Username to access proxy
# @param repo_release
#   Apt release codename
# @param npm_package_ensure 
#   Dist npm package state
# @param npm_package_name
#   Package name for npm package
#

#
class nodejs (
  Boolean $manage_package_repo,
  Boolean $repo_enable_src,
  String $nodejs_debug_package_ensure,
  String $nodejs_dev_package_ensure,
  String $nodejs_package_ensure,
  String $npm_path,
  String $repo_ensure,
  String $repo_priority,
  String $repo_url_suffix,
  Array $gentoo_use_flags = [],
  Boolean $manage_nodejs_package = true,
  Hash $npmrc_config = {},
  Optional[String] $cmd_exe_path = undef,
  Optional[String] $nodejs_debug_package_name = undef,
  Optional[String] $nodejs_dev_package_name = undef,
  Optional[String] $nodejs_package_name = undef,
  Optional[String] $npm_package_ensure = undef,
  Optional[String] $npmrc_auth = undef,
  Optional[String] $package_provider = undef,
  Optional[String] $repo_class = undef,
  Optional[String] $repo_pin = undef,
  Optional[String] $repo_proxy = undef,
  Optional[String] $repo_proxy_password = undef,
  Optional[String] $repo_proxy_username = undef,
  Optional[String] $repo_release = undef,
  Optional[Variant[Boolean, String]] $npm_package_name = undef,
) {
  if $manage_package_repo and !$repo_class {
    fail("${module_name}: manage_package_repo parameter was set to true but no repo_class provided.")
  }

  if $manage_package_repo {
    class { $repo_class:
      ensure         => $repo_ensure,
      enable_src     => $repo_enable_src,
      pin            => $repo_pin,
      priority       => $repo_priority,
      proxy          => $repo_proxy,
      proxy_password => $repo_proxy_password,
      proxy_username => $repo_proxy_username,
      release        => $repo_release,
      url_suffix     => $repo_url_suffix,
      before         => Class['nodejs::install'],
    }
  }

  class { 'nodejs::install':
    gentoo_use_flags            => $gentoo_use_flags,
    manage_nodejs_package       => $manage_nodejs_package,
    nodejs_debug_package_ensure => $nodejs_debug_package_ensure,
    nodejs_debug_package_name   => $nodejs_debug_package_name,
    nodejs_dev_package_ensure   => $nodejs_dev_package_ensure,
    nodejs_dev_package_name     => $nodejs_dev_package_name,
    nodejs_package_ensure       => $nodejs_package_ensure,
    nodejs_package_name         => $nodejs_package_name,
    npm_package_ensure          => $npm_package_ensure,
    npm_package_name            => $npm_package_name,
    npmrc_auth                  => $npmrc_auth,
    npmrc_config                => $npmrc_config,
    package_provider            => $package_provider,
  }
}
