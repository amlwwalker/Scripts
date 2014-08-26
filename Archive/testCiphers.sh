#!/usr/bin/env bash

# OpenSSL requires the port number.
SERVER=$1:443
DELAY=5
ciphers=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')

echo Obtaining cipher list from $(openssl version).
echo $SERVER

for cipher in ${ciphers[@]}
do
echo -n Testing $cipher...
result=$(echo -n | openssl s_client -cipher "$cipher" -connect $SERVER 2>&1)
if [[ "$result" =~ "Cipher is " ]] ; then
  echo YES
else
  if [[ "$result" =~ ":error:" ]] ; then
    error=$(echo -n $result | cut -d':' -f6)
    echo NO \($error\)
  else
    echo UNKNOWN RESPONSE
    echo $result
  fi
fi
sleep $DELAY
done

