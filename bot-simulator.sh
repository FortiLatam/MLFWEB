#!/bin/bash

CONCURRENTBOTCOUNT=5
BOTREQUESTCOUNT=200
URL="http://finance.fortinet.demo/bWAPP/"
################ End of config #################3
# 2019102401 - Ferry Kemps : Initial release
# 2019103101 - Ferry Kemps : Reduce disk load by limit file writing and do it on shared memory

export BOTREQUESTCOUNT URL

function generate-ipaddress {
  while
     set $(dd if=/dev/urandom bs=4 count=1 2>/dev/null | od -An -tu1)
     [ $1 -gt 223 ] &&
     [ $1 -ne 10 ] &&
     { [ $1 -ne 192 ] || [ $2 -ne 168 ]; } &&
     { [ $1 -ne 172 ] || [ $2 -lt 16 ] || [ $2 -gt 31 ]; }
   do :;
  done
  IPADDRESS=$1.$2.$3.$4
}

function simulate-bot {
   BOTIP=$1; BOTREQUESTS=$2
   while [ $BOTREQUESTS -gt 0 ]; do
      wget -U unknown-browser -r -t1 --delete-after --header="X-Forwarded-For:$BOTIP" -o /dev/null $URL
      [ $? != 0 ] && echo "Bot $BOTIP blocked"
      sleep 1
      ((BOTREQUESTS--))
   done
   echo "Bot stopped from : "$BOTIP
}

clear
echo "--------------------------------------------------------------------------"
echo "      FortiWeb Machine Learning - Bot Detection Bot simulator             "
echo "--------------------------------------------------------------------------"

#move to shared memory to lower disk access. Needed for wget recursion out
[ ! -d /dev/shm/1 ] && mkdir /dev/shm/1
cd /dev/shm/1

while [ $CONCURRENTBOTCOUNT -gt 0 ]; do
   generate-ipaddress
   echo "Bot launched from: "$IPADDRESS
   export IPADDRESS
   simulate-bot $IPADDRESS $BOTREQUESTCOUNT &
   sleep 3
   ((CONCURRENTBOTCOUNT--))
done

echo "Wait until BOTs reports to have stopped after $BOTREQUESTCOUNT crawls"
while true; do
   BOTPRGCOUNT=`ps -ef | grep bot-simulator | wc -l`
   [ $BOTPRGCOUNT -le 3 ] && break
   sleep 3
done

# Return to login dir
cd
rm -rf /dev/shm/1
