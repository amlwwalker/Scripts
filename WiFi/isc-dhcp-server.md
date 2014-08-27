# Start the DHCP server. If you don't have it, install it.
# $ dpkg -s isc-dhcp-server # Check what package is installed.
# $ apt-get install isc-dhcp-server

# $ nano /var/log/syslog # To check why it fails if it fails.
# $ nano /etc/dhcp/dhcpd.conf # Configure DHCP. (end of file)
# $ nano /etc/default/isc-dhcp-server # Configure DHCP -- INTERFACE="at0"