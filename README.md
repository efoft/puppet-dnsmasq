# puppet-dnsmasq module
Puppet 4 module to install and configure dnsmasq.

## Installation
Clone into puppet's modules directory.
```
git clone https://github.com/efoft/puppet-dnsmasq.git dnsmasq
```

## Examples of usage
Simple:
```
include dnsmasq
```

Configuration cat be stored in hiera, e.g.:
```
dnsmasq::dhcp_ranges:
  - start: 10.1.1.20
    end: 10.1.1.30
    name: br0
    ttl: 3h
dnsmasq::static_hosts:
  testhost1: 
    ip: 10.1.1.22
    mac: '00:00:00:0c:be:12'
    comment: 'John\s laptop'
```

More complex:
```
class { 'dnsmasq':
  no_host           => true,
  listen_interfaces => ['eth0'],
  dhcp_ranges       => [ {'start' => '10.1.1.20', 'end' => '10.1.1.30', 'ttl' => '12h'}],
}
```
