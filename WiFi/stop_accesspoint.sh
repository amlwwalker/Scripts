#stop connection properly

# Stop monitoring (toss away output)
airmon-ng stop mon0 > /dev/null 2>&1

#Kill Routing
iptables -t nat -D POSTROUTING -o wlan0 -s 192.168.121.0/24 -j MASQUERADE > /dev/null 2>&1
iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080 > /dev/null 2>&1
iptables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8080 > /dev/null 2>&1
echo 0 > /proc/sys/net/ipv4/ip_forward

#Stopping DHCP
service isc-dhcp-server stop > /dev/null 2>&1

#Kill External Access
ifconfig at0 down > /dev/null 2>&1
    sleep 2 

#Kill Access point
basepid=`ps -ef | grep -i [a]irbase | awk '{ print $2 }'`
echo $basepid
kill -9 $basepid > /dev/null 2>&1

#Kill All logs
rm -f /tmp/ap_access_list > /dev/null 2>&1
rm -f /tmp/ethlist > /dev/null 2>&1
rm -Rf /tmp/driftimages > /dev/null 2>&1
rm -f /tmp/pre > /dev/null 2>&1
rm -f /tmp/post > /dev/null 2>&1

rm log.txt