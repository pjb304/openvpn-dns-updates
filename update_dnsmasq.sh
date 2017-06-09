#!/bin/sh
/bin/kill -HUP $(cat /var/run/dnsmasq/dnsmasq.pid)
