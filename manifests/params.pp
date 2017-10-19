#
class dnsmasq::params {
  case $::osfamily {
    'redhat': {
      $package_name = 'dnsmasq'
      $service_name = 'dnsmasq'
      $cfgfile      = '/etc/dnsmasq.conf'
      $confd_dir    = '/etc/dnsmasq.d'
    }
    default: {
      fail('Sorry! Your OS is not supported.')
    }
  }
}
