# ISC-DHCP-SERVER Setup

-
### Installation

~~~bash
# Check what package is installed.
$ dpkg -s isc-dhcp-server 

$ apt-get install isc-dhcp-server
~~~

-
### Configuration

Configuring the DHCP server requires making slight changes to two files. The first one to change is `dhcpd.conf`.

~~~bash
$ nano /etc/dhcp/dhcpd.conf

# at0 configuration
subnet 192.168.99.0 netmask 255.255.255.0 {
	option subnet-mask 255.255.255.0;
	option broadcast-address 192.168.99.255;
	option routers 192.168.99.1;
	default-lease-time 600;
	max-lease-time 7200;
	option domain-name-servers 8.8.8.8, 8.8.4.4;
	range 192.168.99.2 192.168.99.10;
	authorative;
}
~~~

The next file to slightly change is `isc-dhcp-server`

~~~bash
$ nano /etc/default/isc-dhcp-server

# Define the interface we are working with.
INTERFACE="at0"
~~~

-
### Error Handling

When the server fails to start you can check the following file:

~~~bash
$ nano /var/log/syslog

# Make sure to clean it every now and then so it remains readable
$ echo '' > /var/log/syslog
~~~