#!/bin/bash
#ssl with v2 enabled 

apt-get install build-essential devscripts m4 quilt debhelper # There might be more depending on your system - check for error messages
apt-get source openssl
cd openssl-*
quilt pop -a # This removes updates
vi debian/patches/series
#Remove 'no-ssl2.patch' (or whatever it is called now since it has changed before)
vi debian/rules
#Remove 'no-ssl2' in args
quilt push -a # This re-applies the updates, minus the no-ssl2 patch
dch -n 'Allow dangerous v2 protocol'
dpkg-source --commit
debuild -uc -us
ls ../*ssl*.deb
cd ../
sudo dpkg -i *ssl*.deb
#Now you need to do similar activity to get your tools to work again. Here is getting sslscan to work:
apt-get source sslscan
cd sslscan*
debuild -uc -us
cd ../
sudo dpkg -i *sslscan*.deb
