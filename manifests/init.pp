# @summary Installs and configures dnsmasq server.
#   All params that are not covered by this class can be added to dnsmasq via separate .conf files under /etc/dnsmasq.d
#   which is not managed by the class.
#
# @param ensure              If set to `absent` then dnsmasq package will be purged.
# @param bogis_priv          Do not forward queries with private IP to upstream servers.
# @param domain_needed       Do not forward plain name (without domain) queries to upstream servers.
# @param read_ethers         Serve clients with static hosts declarations described in /etc/ethers file.
# @param no_hosts            Do not use info from /etc/hosts when answering queries.
# @param addn_hosts          Can be specified additional hosts file apart from /etc/hosts.
# @param listen_interfaces   Array of interfaces to listen to. If the same interface is mentioned in *except_interfaces* it's excluded.
#   Loopback is always auto-added.

# @param listen_addresses
#   IP to listen on. Can be mixed with *listen_interfaces*. If *listen_interfaces* is not specified, then loopback
#   is not included in resulting set and must be implicitly set here as well.
#
# @param except_interfaces    Do not listen on these interfaces. Overrides *listen_interfaces*.
# @param no_dhcp_interfaces   Disable serving dhcp requests on these interfaces, leaving only dns functionality.
# @param disable_dns          It set to true, port=0 is added to config which completely disables dns functionality of dnsmasq.
# @param log-dhcp & log-dns   Enable or disable logging of queries and dnsmasq answers.
# @param upstream_servers     Servers to query for specific domain. Format: { <domain> => <server ipa>, ... }
# @param pxe_enable           If to include entries allowing pxe clients to receive boot information.
# @param tftp_server          IP of tftp server to boot from. If omitted then dnsmasq assumes IP of this server.
# @param bootfile_bios        Boot file name sent to legacy bios pxe clients.
# @param bootfile_efi_x64     Boot file name sent to UEFI x86_64 pxe clients.
# @param bootfile_efi_ia32    Boot file name sent to UEFI x86(ia32) pxe clients.
#
# @param dhcp_ranges
#   Hash specifying ranges of IP addresses. It can optionally contain the keys:
#   - static_only: only static hosts are served
#   - ttl: lease time, if not specified default 1h is used
#   - options: key-value pairs sent as dhcp-options to clients within this range. See 'dnsmasq --help dhcp'. Can use number or name.
#   Example (hiera format):
#   ---
#   registered:
#     start: 192.168.1.2
#     static_only: true
#   public:
#     start: 192.168.1.220
#     end:   192.168.1.240
#     ttl:   5m
#   provision:
#     start: 192.168.1.190
#     end:   192.168.1.199
#     options:
#       router: 192.168.1.254
#
# @param static_hosts
#   Static hosts declaration. Format:
#   { 'hostname' => { 'ip' => '192.168.1.10', 'mac' => '00:00:00:0c:be:12', 'comment' => 'John's laptop' }...}
#   'comment' is optional and used for description only.
#
# @param include_dir
#   E.g. to include dnsmasq.d directory into config. It proved that empty dnsmasq.d leads to config error on EL6.
#
class dnsmasq (
  Enum['present','absent']      $ensure             = 'present',
  Boolean                       $bogus_priv         = true,
  Boolean                       $domain_needed      = true,
  Boolean                       $read_ethers        = false,
  Boolean                       $no_hosts           = false,
  Optional[String]              $addn_hosts         = undef,
  Array                         $listen_interfaces  = [],
  Array                         $listen_addresses   = [],
  Array                         $except_interfaces  = [],
  Array                         $no_dhcp_interfaces = [],
  Boolean                       $disable_dns        = false,
  Boolean                       $log_dhcp           = false,
  Boolean                       $log_dns            = false,
  Hash                          $upstream_servers   = {},
  Boolean                       $pxe_enable         = false,
  Optional[Stdlib::Ip::Address] $tftp_server        = undef,
  String                        $bootfile_bios      = 'pxelinux.0',
  String                        $bootfile_efi_x64   = 'bootx64.efi',
  String                        $bootfile_efi_ia32  = 'syslinux.efi',
  Hash                          $dhcp_ranges        = {},
  Hash                          $static_hosts       = {},
  Stdlib::Unixpath              $include_dir        = '',
) inherits dnsmasq::params {

  package { $package_name:
    ensure => $ensure ? { 'absent' => 'purged', default => $ensure },
  }

  file { $cfgfile:
    ensure  => $ensure,
    content => template("${module_name}/dnsmasq.conf.erb"),
    require => Package[$package_name],
    notify  => Service[$service_name],
  }

  service { $service_name:
    ensure     => $ensure ? { 'present' => 'running', default => undef },
    enable     => $ensure ? { 'present' => true, default => undef },
    hasstatus  => true,
    hasrestart => true,
  }
}
