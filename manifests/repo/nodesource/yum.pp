##############################################################
#
#   yum
#
##############################################################458
#
# @summary yum subclass
#
# @param enable_src
#   Is this repo enabled?
# @param baseurl
#   The base URL for package repo
# @param descr
#   A description for package repo
# @param ensure
#   Repo absent/present
# @param priority
#   The repo's priority, 1-99 (higher number = lower priority)
# @param source_baseurl
#   The base URL for source repo
# @param source_descr
#   A description for source repo
# @param proxy
#   FQDN of proxy server
# @param proxy_password
#   Password to access proxy server
# @param proxy_username
#   Username to access proxy server
#

#
class nodejs::repo::nodesource::yum (
  Boolean $enable_src,
  String $baseurl,
  String $descr,
  String $ensure,
  String $priority,
  String $source_baseurl,
  String $source_descr,
  Optional[String] $proxy = undef,
  Optional[String] $proxy_password = undef,
  Optional[String] $proxy_username = undef,
) {
  $yum_source_enabled = $enable_src ? {
    true    => '1',
    default => '0',
  }

  if ($ensure == 'present') {
    unless $facts['os']['release']['major'] < '8' {
      file { 'dnf_module':
        ensure => file,
        path   => '/etc/dnf/modules.d/nodejs.module',
        group  => '0',
        mode   => '0644',
        owner  => 'root',
        source => "puppet:///modules/${module_name}/repo/dnf/nodejs.module",
      }
    }

    yumrepo { 'nodesource':
      descr          => $descr,
      baseurl        => $baseurl,
      enabled        => $yum_source_enabled,
      gpgkey         => 'file:///etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL',
      gpgcheck       => '1',
      priority       => $priority,
      proxy          => $proxy,
      proxy_password => $proxy_password,
      proxy_username => $proxy_username,
      require        => File['/etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL'],
    }

    yumrepo { 'nodesource-source':
      descr          => $source_descr,
      baseurl        => $source_baseurl,
      enabled        => $yum_source_enabled,
      gpgkey         => 'file:///etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL',
      gpgcheck       => '1',
      priority       => $priority,
      proxy          => $proxy,
      proxy_password => $proxy_password,
      proxy_username => $proxy_username,
      require        => File['/etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL'],
    }

    file { '/etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL':
      ensure => file,
      group  => '0',
      mode   => '0644',
      owner  => 'root',
      source => "puppet:///modules/${module_name}/repo/nodesource/NODESOURCE-GPG-SIGNING-KEY-EL",
    }
  } else {
    yumrepo { 'nodesource':
      ensure => 'absent',
    }

    yumrepo { 'nodesource-source':
      ensure => 'absent',
    }

    unless $facts['os']['release']['major'] < '8' {
      file { 'dnf_module':
        ensure => absent,
        path   => '/etc/dnf/modules.d/nodejs.module',
      }
    }
  }
}
