##############################################################
#
#   apt
#
##############################################################458
#
# @summary apt subclass
#
# @param enable_src
#   Is this repo enabled?
# @param ensure
#   Repo absent/present
# @param url_suffix
#   Appended to repo URL, essentially the nodejs version
# @param pin
#   Apt repo pinning
# @param release
#   Apt repo release codename
#

#
class nodejs::repo::nodesource::apt (
  Boolean $enable_src,
  String $ensure,
  String $url_suffix,
  Optional[String] $pin = undef,
  Optional[String] $release = undef,
) {
  # include apt

  case $ensure {
    'absent': {
      apt::source { 'nodesource':
        ensure  => 'absent',
        release => $release,
      }
    }
    default: {
      apt::source { 'nodesource':
        include  => {
          'src' => $enable_src,
        },
        key      => {
          'id'     => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
          'source' => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
        },
        location => "https://deb.nodesource.com/node_${url_suffix}",
        pin      => $pin,
        release  => $release,
        repos    => 'main',
      }

      Apt::Source['nodesource'] -> Package<| tag == 'nodesource_repo' |>
      -> Class['Apt::Update'] -> Package<| tag == 'nodesource_repo' |>
    }
  }
}
