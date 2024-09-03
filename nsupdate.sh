#!/bin/bash

echo "$(date): start nsupdate.sh" >> /tmp/nsupdate.log
declare -r IP_OLD="$(head -n1 /tmp/nsupdate)"
declare -r IP_NOW="$(curl -sL https://ip4.me/api | cut -d ',' -f2)"

echo "IP_OLD: $IP_OLD" >> /tmp/nsupdate.log
echo "IP_NEW: $IP_NOW" >> /tmp/nsupdate.log
echo "test if /tmp/nsupdate exist" >> /tmp/nsupdate.log

if [[ ! -e /tmp/nsupdate ]] ; then
  echo "/tmp/nsupdate not exist" >> /tmp/nsupdate.log
  echo "$IP_NOW" > /tmp/nsupdate
fi

if ! [[ "$IP_NOW" = "$(cat /tmp/nsupdate)" ]] ; then
  echo "update nsupdate and update /tmp/nsupdate" >> /tmp/nsupdate.log
  echo "$IP_NOW" > /tmp/nsupdate
  curl -s https://DNSNAME:PASSWORD@ipv4.nsupdate.info/nic/update > /dev/null
else
  echo "not update" >> /tmp/nsupdate.log
fi

echo "end:" >> /tmp/nsupdate.log
