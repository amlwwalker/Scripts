#!/bin/bash

declare -a autoInstall=(
'libnl-dev'
'build-essential'
'libssl-dev'
'libpcap-dev'
'sqlite3'
'libsqlite3-dev'
'libpcap0.8-dev' 
'make'
'cmake' #essentials finished
'dialog' #toolbox
'expect'
'rsh-client'
'smbclient'
'p7zip'
'finger'
'sslscan'
'nikto'
'arp-scan'
'nmap'
'amap'
'fping'
'traceroute'
'tcptraceroute'
'tcpdump'
'wireshark'
'dsniff'
'sslstrip'
'hping3'
'sipcalc'
);
#Programs to manual install
declare -a manualInstall=(
'john the ripper'
'ophcrack'
'hydra: "http://www.thc.org/download.php?t=r&f=hydra-7.4.2.tar.gz"'
'hoppy: "http://labs.portcullis.co.uk/download/hoppy-1.7.3.tar.bz2"'
'airodump-ng: "http://download.aircrack-ng.org/aircrack-ng-1.2-beta1.tar.gz"'
'reaver: "http://reaver-wps.googlecode.com/files/reaver-1.4.tar.gz"'
'metasploit: "http://downloads.metasploit.com/data/releases/metasploit-latest-linux-installer.run"'
'nessus: "http://www.tenable.com/products/nessus/select-your-operating-system"'
'whatmask: "wget http://downloads.laffeycomputer.com/current_builds/whatmask/whatmask-1.2.tar.gz"'
);
isInstalled() {
if (type -p "$1" > /dev/null) ; then 
	 return 0
else
	return 1
fi
}

isFileExists(){
local f="$1"
	[[ -f "$f" ]] && return 0 || return 1
}
#test if root
ROOT_UID=0
if [ $UID != $ROOT_UID ]; then
	echo "Need to be root"
	exit 1;
fi


for i in "${autoInstall[@]}"

do
	if (isInstalled "$i" ) then 
		echo "$i installed"
	else
		echo "$i not installed, downloading from repo"
		apt-get install $i
fi
done

printf "\n\033[1mThe following programs need installing manually\033[0m\n\n"
for i in "${manualInstall[@]}"
do
	printf "\033[2m$i\033[0m\n"
done

