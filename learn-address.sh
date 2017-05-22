#!/bin/sh
# openvpn learn-address script to manage a hosts-like file
# - intended to allow dnsmasq to resolve openvpn clients
#   addn-hosts=/etc/hosts.openvpn-clients
# - written for openwrt (busybox), but should work most anywhere
#
# Changelog
# 2006-10-13 BDL original

# replace with a sub-domain of your domain, use a sub-domain to  
#prevent VPN clients from stealing existing names

DOMAIN=vpn.example.net

HOSTS=/etc/hosts.openvpn-clients

h=$(/usr/bin/basename "$HOSTS")
LOCKFILE="/var/run/$h.lock"

IP="$2"
CN="$3"
case "$1" in
   add|update)
     if [ -z "$IP" -o -z "$CN" ]; then
         echo "$0: IP and/or Common Name not provided" >&2
         exit 0
     fi
   ;;
   delete)
     if [ -z "$IP" ]; then
         echo "$0: IP not provided" >&2
         exit 0
     fi
   ;;
   *)
     echo "$0: unknown operation [$1]" >&2
     exit 1
   ;;
esac


# serialise concurrent accesses
[ -x /bin/lock ] && /bin/lock "$LOCKFILE"

# clean up IP if we can
[ -x /bin/ipcalc ] && eval $(ipcalc "$IP")

FQDN="$CN.$DOMAIN"

# busybox mktemp must have exactly six X's
t=$(/bin/mktemp "/tmp/$h.XXXXXX")
if [ $? -ne 0 ]; then
     echo "$0: mktemp failed" >&2
     exit 1
fi


case "$1" in

   add|update)
    /usr/bin/awk '  BEGIN{ print "***";if(match("'"$IP"'",/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)){ipv4=1}}
$1 == "'"$IP"'" || $1 == "#'"$IP"'"  { if (!m){ print "'"$IP"'\t'"$FQDN"'"; m=1; next }} # This looks for any line which matches either the IP address / commented IP address (this can only happen once)
match($1, /\#?[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/) && $2 == "'"$FQDN"'" { if (!m && ipv4){ print "'"$IP"'\t'"$FQDN"'"; m=1; next }else{print $0;next}} #Looks for any ipv4 address and the fqdn and updates only if the input is v4
match($1, /\#?[0-9A-Fa-f:]+/)  && $2 == "'"$FQDN"'" { if (!m && !ipv4){ print "'"$IP"'\t'"$FQDN"'"; m=1; next }else{print $0;next}} #Looks for any ipv6 address and the fqdn and updates only if the input is v6
{ print }
END { if (!m) print "'"$IP"'\t'"$FQDN"'"}           # add new address to end
     ' "$HOSTS" > "$t" && cat "$t" > "$HOSTS"
   ;;

   delete)
     /usr/bin/awk '
         # no FQDN, comment out all matching addresses (should only be one)
         $1 == "'"$IP"'" { print "#" $0; next }
         { print }
     ' "$HOSTS" > "$t" && cat "$t" > "$HOSTS"
   ;;

esac
# signal dnsmasq to reread hosts file
/bin/kill -HUP $(cat /var/run/dnsmasq/dnsmasq.pid)

rm -r $t
[ -x /bin/lock ] && /bin/lock -u "$LOCKFILE"
exit 0
