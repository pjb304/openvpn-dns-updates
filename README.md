# openvpn-dns-updates

A script to update a local DNS server (dnsmasq) when a client connects.  Initial version from https://openvpn.net/archive/openvpn-users/2006-10/msg00119.html

This uses a seperate file for IPv4 and IPv6 addresses because if they are in the same file dnsmasq only uses the first one

## Installation

To install place the learn-address.sh file in /var/lib/openvpn (you may have to create this folder).  

Add the following to the specified files

### /etc/openvpn/server.conf (Or your active server config if elsewhere)
```
learn-address /var/lib/openvpn/learn-address.sh
```


### /etc/dnsmasq/dnsmasq.conf
```
addn-hosts=/etc/hosts.openvpn-clients4
addn-hosts=/etc/hosts.openvpn-clients6
```
The ttl for entries gathered from local files can be set using the argument below.  Setting this is a balance of load vs responsiveness to change
```
local-ttl=5
```
Create the files
/etc/hosts.openvpn-clients4
/etc/hosts.openvpn-clients6

The changer the owner to be nobody:nogroup to allow the update to write to them.

### crontab
```
* * * * * /var/lib/openvpn/update_dnsmasq.sh
```

This is to make dnsmasq refresh the hosts file every minute.  I have not yet worked out how to get openvpn to send the message to dnsmasq as by the point it is calling this script it is running as nobody:nogroup so does not have the required permissions.  If you get this working please submit a pull request so I can add it in.


