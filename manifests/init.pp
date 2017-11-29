# === Class dnsmasq ===
# Installs and configures dnsmasq server.
#
# All params that are not covered by this class can be added to dnsmasq via separate .conf files under /etc/dnsmasq.d
# which is not managed by the class.
#
# === Parameters ===
# [*ensure*]
#   If set to `absent` then dnsmasq packed will be purged.
#
# [*service_ensure*]
#   Option to manage service separately from *ensure* param.
#   It only plays a role when *ensure* is present. If absent then the service is unmanaged anyway.
#   Default: running
#
# [*bogis_priv*]
#   Do not forward queries with private IP to upstream servers.
#   Default: true
#
# [*domain_needed*]
#   Do not forward plain name (without domain) queries to upstream servers.
#   Default: true
#
# [*read_ethers*]
#   Serve clients with static hosts declarations described in /etc/ethers file.
#   Default: false
#
# [*no_hosts*]
#   Do not use info from /etc/hosts when answering queries.
#   Default: false
#
# [*addn_hosts*]
#   Can be specified additional hosts file apart from /etc/hosts.
#
# [*listen_interfaces*]
#   Array of interfaces to listen to. If the same interface is mentioned in *except_interfaces* it's excluded.
#   Loopback is always auto-added.
#
# [*listen_addresses*]
#   IP to listen on. Can be mixed with *listen_interfaces*. If *listen_interfaces* is not specified, then loopback
#   is not included in resulting set and must be implicitly set here as well.
#
# [*except_interfaces*]
#   Do not listen on these interfaces. Overrides *listen_interfaces*.
#
# [*no_dhcp_interfaces*]
#   Disable serving dhcp requests on these interfaces, leaving only dns functionality.
#
# [*disable_dns*]
#   It set to true, port=0 is added to config which completely disables dns functionality of dnsmasq.
#   Default: false
#
# [*log-dhcp*] & [*log-dns*]
#   Enable or disable logging of queries and dnsmasq answers.
#   Default: false
#
# [*upstream_servers*]
#   Servers to query for specific domain. Format: { <domain> => <server ipa>, ... }
#
# [*pxe_next_server*]
#   IP of pxe boot server. If omitted then dnsmasq assumes IP of this server.
#
# [*pxe_filename*]
#   Name of boot image file for pxe booting.
#
# [*dhcp_ranges*]
#   Hash specifying ranges of IP addresses. It can optionally contain the keys:
#   - static_only: only static hosts are served
#   - ttl: lease time, if not specified default 1h is used
#   - pxe: set to true to enable pxe booting with this range
#   - next_server: IP of pxe boot server, if omitted then IP of this server is used
#   Example (hiera format):
#   ---
#   registered:
#     start: 192.168.1.2
#     end:   192.168.1.199
#     static_only: true
#   public:
#     start: 192.168.1.220
#     end:   192.168.1.240
#     ttl:   5m
#   pxe:
#     start: 192.168.1.290
#     end:   192.168.1.299
#     pxe:   true
#
# [*static_hosts*]
#   Static hosts declaration. Format:
#   { 'hostname' => { 'ip' => '192.168.1.10', 'mac' => '00:00:00:0c:be:12', 'comment' => 'John's laptop' }...}
#   'comment' is optional and used for description only.
#
class dnsmasq(
  Enum['present','absent'] $ensure                = 'present',
  Enum['running','stopped'] $service_ensure       = 'running',
  Boolean $bogus_priv                             = true,
  Boolean $domain_needed                          = true,
  Boolean $read_ethers                            = false,
  Boolean $no_hosts                               = false,
  Optional[String] $addn_hosts                    = undef,
  Array $listen_interfaces                        = [],
  Array $listen_addresses                         = [],
  Array $except_interfaces                        = [],
  Array $no_dhcp_interfaces                       = [],
  Boolean $disable_dns                            = false,
  Boolean $log_dhcp                               = false,
  Boolean $log_dns                                = false,
  Hash $upstream_servers                          = {},
  Optional[Stdlib::Compat::Ipv4] $pxe_next_server = undef,
  String $pxe_filename                            = 'pxelinux.0',
  Hash $dhcp_ranges                               = {},
  Hash $static_hosts                              = {},
) inherits dnsmasq::params {

  package { $dnsmasq::params::package_name:
    ensure => $ensure ? { 'absent' => 'purged', default => $ensure },
  }

  file { $dnsmasq::params::cfgfile:
    ensure  => $ensure,
    content => template('dnsmasq/dnsmasq.conf.erb'),
    require => Package[$dnsmasq::params::package_name],
    notify  => Service[$dnsmasq::params::service_name],
  }

  $service_enable = $service_ensure ?
  {
    'running' => true,
    'stopped' => false
  }
  service { $dnsmasq::params::service_name:
    ensure     => $ensure ? { 'present' => $service_ensure, 'absent' => undef },
    enable     => $ensure ? { 'present' => $service_enable, 'absent' => undef },
    hasstatus  => true,
    hasrestart => true,
  }
}
