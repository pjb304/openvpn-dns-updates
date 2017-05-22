# openvpn-dns-updates

A script to update a local DNS server (dnsmasq) when a client connects.  Initial version from https://openvpn.net/archive/openvpn-users/2006-10/msg00119.html

To install place the learn-address.sh file in /var/lib/openvpn (you may have to create this folder).  

Add the following to the specified files

### /etc/openvpn/server.conf (Or you active server config if elsewhere)
```
learn-address /var/lib/openvpn/learn-address.sh
```


### /etc/dnsmasq/dnsmasq.conf
```
addn-hosts=/etc/hosts.openvpn-clients
```

Create the file /etc/hosts.openvpn-clients 

The changer the owner to be nobody:nogroup to allow the update to write to it.



