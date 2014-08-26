#!/bin/bash

#Script to help with sorting open ports and their functions from nmap output (.nmap) file
#OPTIONS: (getopt)
# Execute getopt
ARGS=$(getopt -o f:t:c: -l "file:,transport:,csv" -n "getopt.sh" -- "$@");

#Bad arguments
if [ $? -ne 0 ];
then
  exit 1
fi

echo
echo "An Alternative Analysis"
#----------------------------------------------This handles the switches (f/t/c)---------------------------------------------------------
useCSV="false";
filename="";
transport="";
eval set -- "$ARGS";
while true; do
  case "$1" in
    -f|--file)
      shift;
      if [ -n "$1" ]; then
	filename=$1;
        echo "filename: $1";
        shift;
      fi
      ;;
    -t|--transport)
	shift;
      if [ -n "$1" ]; then
	transport=$1;
	#if [[ (("$transport" != "u")) && (("$transport" != "udp")) && (("$transport" != "t")) && (("$transport" != "tcp")) ]]; then
	echo "please choose a valid protocol tag";
	#exit;
	#fi
	echo "transport protocol: $transport";
      shift;
      fi
      ;;
    -c|--csv)
	shift;
	if [ -n "$1" ]; then	
	useCSV=$1;
        shift;
	fi
      ;;
    --)
      shift;
     break;
      ;;
  esac
done

#----------------------------------------------Always require a filename
if [[ "$filename" == "" ]] 
then
echo "Please supply an nmap (.nmap file). To output in CSV format, use the -c option followed by a delimiter";
echo "example: ./formatNmap.sh -f my.nmap.file.nmap -t udp -c ,"
exit;
fi

#---------------------------------Actual Program. Process nmap file and run amap in TCP/UDP mode depending on switch set
while read line; 
do
	if [[ "$line" == *'Nmap scan report for'* ]] #search for line containing the ip address
	then
		ipaddr=$(echo "\r\n"$line | awk -F' ' '{ print $5 }') #print ip address
		echo 
		echo $ipaddr 
		echo "PORT STATE [amap]SERVICE"
	elif [[ "$line" == *' open '* ]] #output open ports for that ip address
	then
		port=$(echo $line | awk -F' ' '{ print $1 }' | awk -F'/' '{ print $1 }') 
		
		if [[ "$transport" == "udp" || "$transport" = "u" ]]
		then
		echo "Using UDP protocol"		
		protocol=$(amap -u $ipaddr $port | grep -i "protocol" | awk -F' ' '{ print $5 }')
		else
		echo "Using TCP protocol"
		protocol=$(amap $ipaddr $port | grep -i "protocol" | awk -F' ' '{ print $5 }')
		fi
		
		if [[ "$useCSV" == "false" ]]
		then	
			echo $port " open " $protocol
		else
			echo $port"$useCSV""open""$useCSV"$protocol"$useCSV"
		fi	
	fi

done < $filename

