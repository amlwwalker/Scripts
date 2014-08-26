#!/bin/bash
#update java
add-apt-repository ppa:webupd8team/java
pt-get update
apt-get install oracle-java7-installer
update-java-alternatives -s java-7-oracle
