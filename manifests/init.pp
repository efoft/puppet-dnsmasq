# === Class dnsmasq ===
# Installs and configures dnsmasq server.
#
# All params that are not covered by this class can be added to dnsmasq via separate .conf files under /etc/dnsmasq.d
# which is not managed by the class.
#
# === Parameters ===
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
# [*pxe*]
#   If true the specially tagged network range is included to server booting via network clients.
#   Default: false
#
# [*pxe_range_start*] & [*pxe_range_end*]
#   Address range for booting clients. Mandatory if *pxe* = true.
#
# [*pxe_listen_ip*]
#   Optional parameter to specify on which IP to listen to bootp requests.
#
# [*dhcp_ranges*]
#   Array of hashes each specifying range and optionally network name and leasetime(ttl). Format:
#   [{ 'start' => '192.168.1.2', 'end' => '192.168.1.254', 'name' => 'eth0', 'ttl' => '12h' }, ...]
#
# [*static_hosts*]
#   Static hosts declaration. Format:
#   { 'hostname' => { 'ip' => '192.168.1.10', 'mac' => '00:00:00:0c:be:12', 'comment' => 'John's laptop' }...}
#   'comment' is optional and used for description only.
#
class dnsmasq(
  Enum['present','absent'] $ensure  = 'present',
  Boolean $bogus_priv               = true,
  Boolean $domain_needed            = true,
  Boolean $read_ethers              = false,
  Boolean $no_hosts                 = false,
  Optional[String] $addn_hosts      = undef,
  Array $listen_interfaces          = [],
  Array $listen_addresses           = [],
  Array $except_interfaces          = [],
  Array $no_dhcp_interfaces         = [],
  Boolean $disable_dns              = false,
  Boolean $log_dhcp                 = false,
  Boolean $log_dns                  = false,
  Hash $upstream_servers            = {},
  Boolean $pxe                      = false,
  Optional[String] $pxe_range_start = undef,
  Optional[String] $pxe_range_end   = undef,
  String $pxe_boot_file             = 'pxelinux.0',
  Optional[String] $pxe_listen_ip   = undef,
  Tuple $dhcp_ranges                = [],
  Hash $static_hosts                = {},
) inherits dnsmasq::params {

  if $pxe and ! $pxe_range_start {
    fail('Parameters pxe_range_start, pxe_range_stop are required if pxe = true.')
  }

  package { $dnsmasq::params::package_name:
    ensure => $ensure ? { 'absent' => 'purged', default => $ensure },
  }

  file { $dnsmasq::params::cfgfile:
    ensure  => $ensure,
    content => template('dnsmasq/dnsmasq.conf.erb'),
    require => Package[$dnsmasq::params::package_name],
    notify  => Service[$dnsmasq::params::service_name],
  }


  service { $dnsmasq::params::service_name:
    ensure => $ensure ? { 'present' => 'running', 'absent' => undef },
    enable => $ensure ? { 'present' => true,      'absent' => undef },
  }
}
