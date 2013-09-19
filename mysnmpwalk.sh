#!/bin/bash
# $1 is ip to request snmp info
snmpwalk -v 1 -c public -O e $1
