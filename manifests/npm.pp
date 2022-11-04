##############################################################
#
#   npm
#
##############################################################458
#
# @summary Defined type for npm
#
# @param target
#
# @param ensure
#
# @param cmd_exe_path
#
# @param install_options
#
# @param npm_path
#
# @param package
#
# @param source
#
# @param uninstall_options
#
# @param home_dir
#
# @param user
#
# @param use_package_json 
#

#
define nodejs::npm (
  Array $install_options = [],
  Array $uninstall_options  = [],
  Boolean $use_package_json = false,
  Pattern[/^[^<            >= ]/] $ensure = 'present',
  Stdlib::Absolutepath $target,
  String $home_dir = '/root',
  String $npm_path = $nodejs::npm_path,
  String $package = $title,
  String $source = 'registry',
  Optional[String] $cmd_exe_path = $nodejs::cmd_exe_path,
  Optional[String] $user = undef,
) {
  $install_options_string = join($install_options, ' ')
  $uninstall_options_string = join($uninstall_options, ' ')

  # Note that install_check will always return false when a remote source is
  # provided
  if $source != 'registry' {
    $install_check_package_string = $source
    $package_string = $source
  } elsif $ensure =~ /^(present|absent)$/ {
    $install_check_package_string = $package
    $package_string = $package
  } else {
    # ensure is either a tag, version or 'latest'
    # Note that install_check will always return false when 'latest' or a tag is
    # provided
    # npm ls does not keep track of tags after install
    $install_check_package_string = "${package}:${package}@${ensure}"
    $package_string = "${package}@${ensure}"
  }

  $grep_command = $facts['os']['family'] ? {
    'Windows' => "${cmd_exe_path} /c findstr /l",
    default   => 'grep',
  }

  $dirsep = $facts['os']['family'] ? {
    'Windows' => '\\',
    default   => '/'
  }

  $list_command = "${npm_path} ls --long --parseable"
  $install_check = "${list_command} | ${grep_command} \"${target}${dirsep}node_modules${dirsep}${install_check_package_string}\""

  # set a sensible path on Unix
  $exec_path = $facts['os']['family'] ? {
    'Windows' => undef,
    'Darwin'  => ['/bin', '/usr/bin', '/opt/local/bin', '/usr/local/bin'],
    default    => ['/bin', '/usr/bin', '/usr/local/bin'],
  }

  if $ensure == 'absent' {
    $npm_command = 'rm'
    $options = $uninstall_options_string

    if $use_package_json {
      exec { "npm_${npm_command}_${name}":
        command => "${npm_path} ${npm_command} * ${options}",
        path    => $exec_path,
        onlyif  => $list_command,
        user    => $user,
        cwd     => "${target}${dirsep}node_modules",
        require => Class['nodejs'],
      }
    } else {
      exec { "npm_${npm_command}_${name}":
        command => "${npm_path} ${npm_command} ${package_string} ${options}",
        path    => $exec_path,
        onlyif  => $install_check,
        user    => $user,
        cwd     => $target,
        require => Class['nodejs'],
      }
    }
  } else {
    $npm_command = 'install'
    $options = $install_options_string

    # Conditionally require proxy and https-proxy to be set first only if the resource exists.
    Nodejs::Npm::Global_config_entry<| title == 'https-proxy' |> -> Exec["npm_install_${name}"]
    Nodejs::Npm::Global_config_entry<| title == 'proxy' |> -> Exec["npm_install_${name}"]

    if $use_package_json {
      exec { "npm_${npm_command}_${name}":
        command     => "${npm_path} ${npm_command} ${options}",
        path        => $exec_path,
        unless      => $list_command,
        user        => $user,
        cwd         => $target,
        environment => "HOME=${home_dir}",
        require     => Class['nodejs'],
      }
    } else {
      exec { "npm_${npm_command}_${name}":
        command     => "${npm_path} ${npm_command} ${package_string} ${options}",
        path        => $exec_path,
        unless      => $install_check,
        user        => $user,
        cwd         => $target,
        environment => "HOME=${home_dir}",
        require     => Class['nodejs'],
      }
    }
  }
}
