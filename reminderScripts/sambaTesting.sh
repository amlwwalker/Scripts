#!/bin/bash

#Commands for samba hacking that can be useful:
#$1 is ip address
nmblookup -A $1
#The above gives you the samba share name, use that in place of [] here
smbclient -L //[] -I $1


