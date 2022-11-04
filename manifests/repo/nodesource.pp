##############################################################
#
#   nodesource
#
##############################################################458
#
# @summary nodesource subclass
#
# @param enable_src
#   Is this repo enabled?
# @param ensure
#   Repo absent/present
# @param priority
#   The repo's priority, 1-99 (higher number = lower priority)
# @param url_suffix
#   Appended to repo URL, essentially the nodejs version
# @param pin
#   Apt repo pinning
# @param proxy
#   FQDN of proxy server
# @param proxy_password
#   Password to access proxy server
# @param proxy_username
#   Username to access proxy server
# @param release
#   Apt repo release codename
#

#
class nodejs::repo::nodesource (
  Boolean $enable_src,
  String $ensure,
  String $priority,
  String $url_suffix,
  Optional[String] $pin = undef,
  Optional[String] $proxy = undef,
  Optional[String] $proxy_password = undef,
  Optional[String] $proxy_username = undef,
  Optional[String] $release = undef,
) {
  case $facts['os']['family'] {
    'RedHat': {
      case $facts['os']['name'] {
        'CentOS', 'OracleLinux', 'RedHat': {
          $dist_type = 'el'
          $dist_version = $facts['os']['release']['major']
          $name_string  = "Enterprise Linux ${dist_version}"
        }
        'Fedora': {
          $dist_type = 'fc'
          $dist_version = $facts['os']['release']['full']
          $name_string = "Fedora Core ${facts['os']['release']['full']}"
        }
        default: {
          fail("Encountered unexpected OS: ${facts['os']['name']} ${facts['os']['release']['full']}!")
        }
      }
      # nodesource repo
      $descr   = "Node.js Packages for ${name_string} - \$basearch"
      $baseurl = "https://rpm.nodesource.com/pub_${url_suffix}/${dist_type}/${dist_version}/\$basearch"

      # nodesource-source repo
      $source_descr   = "Node.js for ${name_string} - \$basearch - Source"
      $source_baseurl = "https://rpm.nodesource.com/pub_${url_suffix}/${dist_type}/${dist_version}/SRPMS"

      class { 'nodejs::repo::nodesource::yum':
        baseurl        => $baseurl,
        descr          => $descr,
        enable_src     => $enable_src,
        ensure         => $ensure,
        priority       => $priority,
        proxy          => $proxy,
        proxy_password => $proxy_password,
        proxy_username => $proxy_username,
        source_baseurl => $source_baseurl,
        source_descr   => $source_descr,
      }
    }
    'Debian': {
      class { 'nodejs::repo::nodesource::apt':
        enable_src => $enable_src,
        ensure     => $ensure,
        pin        => $pin,
        release    => $release,
        url_suffix => $url_suffix,
      }
    }
    default: {
      fail("Encountered unexpected osfamily: ${facts['os']['family']}")
    }
  }
}
