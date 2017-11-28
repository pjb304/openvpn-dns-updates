# openvpn-dns-updates

A script to update a local DNS server (dnsmasq) when a client connects.  Initial version from https://openvpn.net/archive/openvpn-users/2006-10/msg00119.html

This uses a seperate file for IPv4 and IPv6 addresses because if they are in the same file dnsmasq only uses the first one.

Both dnsmasq and openvpn have to be running as the same user.  I create one specially for this.

## Installation

To install place the learn-address.sh file in /var/lib/openvpn (you may have to create this folder).  

Add the following to the specified files

### /etc/openvpn/server.conf (Or your active server config if elsewhere)
```
learn-address /var/lib/openvpn/learn-address.sh
user openvpn

```


### /etc/dnsmasq.conf
```
addn-hosts=/etc/hosts.openvpn-clients4
addn-hosts=/etc/hosts.openvpn-clients6
user=openvpn
```
The ttl for entries gathered from local files can be set using the argument below.  Setting this is a balance of load vs responsiveness to change
```
local-ttl=5
```
Create the files, and change the owner to the same as the user that both openvpn and dnsmasq will run as
```
/etc/hosts.openvpn-clients4
/etc/hosts.openvpn-clients6
chown openvpn /etc/hosts.openvpn-clients4
chown openvpn /etc/hosts.openvpn-clients6
```



