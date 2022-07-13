#!/bin/bash

# This script is used to present a menu from which you provide input for FortiWeb Machine Learning traffic generation.
# 2018061201 : Ferry Kemps : Initial release
# 2018070901 : Ferry Kemps : Modified for Advanced Workshop

initall() {
  COUNTER=1
  COUNT=0
  RANGE=255
  I=1
  SP=" / - \ |"
}

mainmenu() {
  clear
  echo " ------------------------------------------------------------------------------"
  echo "                   FortiWeb Machine Learning request generator                 "
  echo " ------------------------------------------------------------------------------"
  echo ""
  echo "  1 - 7.000 POST requests for param1 with hexadecimal format"
  echo "  2 - 5.000 POST requests for param1 with date format"
  echo "  3 - 7.000 POST requests for param2 with hexadecimal format"
  echo "  4 - 5.000 POST requests for param2 with date format"
  echo "  9 - custom requests, specify amount, URL, method, parameter, data-type"
  echo ""
  echo "  q - Exit"
  echo ""
}

pause(){
  echo ""
  read -p "Press [Enter] key to continue..." fackEnterKey
}

read_input(){
    local choice
    read -p "Enter choice [ 1 - 9] " choice
    case $choice in
        1) param1POSTmacaddr ;;
        2) param1POSTdate ;;
        3) param2POSTmacaddr ;;
        4) param2POSTdate ;;
        9) customrequest ;;
        q) exit 0;;
        Q) exit 0;;
        *) echo -e "${RED}Error...${STD}" && sleep 1
    esac
}

firerequest-date() {
   until [ $COUNTER -eq $COUNT ]
   do
     temp=$(echo "$RANDOM * $RANDOM * $RANDOM / 1000" | bc -l)
     temp2=$(date -d @$temp)
      curl -A ML-requester -s -o /dev/null -X $METHOD -H "Content-Type: $CONTENTTYPE" $URL -d "$PARAMETER=$temp2&submit=submit"
     sleep 0.02
     let "COUNTER += 1"  # Increment count.
     printprogress $COUNTER
   done
}

firerequest-macaddr() {
   until [ $COUNTER -eq $COUNT ]
   do
     numbera=$RANDOM
     numberb=$RANDOM
     numberc=$RANDOM
     numberd=$RANDOM
     numbere=$RANDOM
     numberf=$RANDOM

     let "numbera %= $RANGE"
     let "numberb %= $RANGE"
     let "numberc %= $RANGE"
     let "numberd %= $RANGE"
     let "numbere %= $RANGE"
     let "numberf %= $RANGE"

     octeta=`echo "obase=16;$numbera" | bc`
     octetb=`echo "obase=16;$numberb" | bc`
     octetc=`echo "obase=16;$numberc" | bc`
     octetd=`echo "obase=16;$numberd" | bc`
     octete=`echo "obase=16;$numbere" | bc`
     octetf=`echo "obase=16;$numberf" | bc`

     macadd="${octeta}${octetb}${octetc}${octetd}${octete}${octetf}"

      curl -A ML-requester -s -o /dev/null -X $METHOD -H "Content-Type: $CONTENTTYPE" $URL -d "$PARAMETER=$macadd&submit=submit"
     sleep 0.02
     let "COUNTER += 1"  # Increment count.
     printprogress $COUNTER
   done
}

customrequest() {
  echo ""
  read -p "Amount of requests: " COUNT
  read -p "URL (http://dvwa.fortinet.demo/param1234.htm) " URL
  read -p "Method (GET, POST, PUT, DELETE, OPTIONS, HEAD) : " METHODIN
  read -p "Parameter name : " PARAMETER
  read -p "Parameter type (date, postal, email, phone, random, number-small, number-big) : " PARAMETERTYPE
  echo ""; echo -n "Started  : "; date; echo -n "Requests : "

  METHOD=`echo $METHODIN | tr [:lower:] [:upper:]`

  [ -z $URL ] && URL="http://dvwa.fortinet.demo/param1234.htm"
  if [ -z $COUNT ] || [ -z $URL ] || [ -z $METHODIN ] || [ -z PARAMETER ] || [ -z $PARAMETERTYPE ]
  then
    echo "ERROR: empty input detected"
    return
  elif [ $METHOD != "GET" ] && [ $METHOD != "POST" ] && [ $METHOD != "PUT" ] && [ $METHOD != "DELETE" ] && [ $METHOD != "OPTIONS" ] && [ $METHOD != "HEAD" ]
  then
    echo "ERROR: Invalid method given"
    return
  elif [[ $URL != *http* ]]
  then
    echo "ERROR: Invalid URL given"
    return
  fi


  until [ $COUNTER -eq $COUNT ]
  do
    if [ $PARAMETERTYPE = "date" ]
    then
     temp=$(echo "$RANDOM * $RANDOM * $RANDOM / 1000" | bc -l)
     PARAMETERVALUE=$(date -d @$temp)
    elif [ $PARAMETERTYPE = "postal" ]
    then
      POSTALNUMERIC_LENGTH=4
      POSTALALPHA_LENGTH=2
      POSTALNUMERIC=$(cat /dev/urandom | tr -dc '0-9' | fold -w $POSTALNUMERIC_LENGTH | head -n 1)
      POSTALALPHA=$(cat /dev/urandom | tr -dc 'A-Z' | fold -w $POSTALALPHA_LENGTH | head -n 1)
      PARAMETERVALUE=$POSTALNUMERIC$POSTALALPHA
    elif [ $PARAMETERTYPE = "email" ]
    then
      NAME_LENGTH=`shuf -i 4-15 -n 1`
      DOMAIN_LENGTH=`shuf -i 5-20 -n 1`
      EXT_LENGTH=`shuf -i 3-4 -n 1`
      USER_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $NAME_LENGTH | head -n 1)
      DOMAIN_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $DOMAIN_LENGTH | head -n 1)
      DOMAIN_EXT=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w $EXT_LENGTH | head -n 1)
      PARAMETERVALUE=$USER_NAME@$DOMAIN_NAME.$DOMAIN_EXT
    elif [ $PARAMETERTYPE = "phone" ]
    then
      COUNTRYCODE=`shuf -i 1-99 -n 1`
      AREAPHONE=`shuf -i 100000000-999999999 -n 1`
      PARAMETERVALUE="%2B$COUNTRYCODE-$AREAPHONE"
    elif [ $PARAMETERTYPE = "random" ]
    then
      RANDOM_LENGTH=15
      PARAMETERVALUE="$(cat /dev/urandom | tr -dc [:print:] | fold -w $RANDOM_LENGTH | head -n 1| sed s/[\?\&]//g)"
    elif [ $PARAMETERTYPE = "number-small" ]
    then
      PARAMETERVALUE=`shuf -i 0-100 -n 1`
    elif [ $PARAMETERTYPE = "number-big" ]
    then
      PARAMETERVALUE=`shuf -i 1000-10000000 -n 1`
    else
      echo "ERROR: no valid type selected"
      return
    fi

    [ $METHOD == GET ]  && ( WEBPARAMETERVALUE=`echo $PARAMETERVALUE | sed s/\ /%20/g` ; curl -A ML-tester -s "$URL?$PARAMETER=$WEBPARAMETERVALUE" -o /dev/null)
    [ $METHOD == POST ]  && curl -A ML-tester -s -X $METHOD $URL -d "$PARAMETER=$PARAMETERVALUE" -o /dev/null
    [ $METHOD == PUT ]  && curl -A ML-tester -s -X $METHOD $URL -d "$PARAMETER=$PARAMETERVALUE" -o /dev/null
    [ $METHOD == DELETE ]  && curl -A ML-tester -s -X $METHOD $URL -d "$PARAMETER=$PARAMETERVALUE" -o /dev/null
    [ $METHOD == OPTIONS ]  && curl -A ML-tester -s -X $METHOD $URL -d "$PARAMETER=$PARAMETERVALUE" -o /dev/null
    [ $METHOD == HEAD ]  && curl -A ML-tester -s -X $METHOD $URL -o /dev/null
     sleep 0.02
     let "COUNTER += 1"  # Increment count.
     printprogress $COUNTER
  done
}

printprogress() {
  [[ $1 = *5 ]] && printf "\b${SP:I++%${#SP}:1}"
  [[ $1 = *00 ]] && echo -n "$1 "
}

param1POSTdate() {
  PARAMETER="param1"
  COUNT=5000
  URL="http://dvwa.fortinet.demo/param1234.htm"
  METHOD="POST"
  CONTENTTYPE="application/x-www-form-urlencoded"
  echo ""; echo -n "Started: "; date; echo -n "Requests : "
  firerequest-date
}

param2POSTdate() {
  PARAMETER="param2"
  COUNT=5000
  URL="http://dvwa.fortinet.demo/param1234.htm"
  METHOD="POST"
  CONTENTTYPE="application/x-www-form-urlencoded"
  echo ""; echo -n "Started: "; date; echo -n "Requests : "
  firerequest-date
}

param1POSTmacaddr() {
  PARAMETER="param1"
  COUNT=7000
  URL="http://dvwa.fortinet.demo/param1234.htm"
  METHOD="POST"
  CONTENTTYPE="application/x-www-form-urlencoded"
  echo ""; echo -n "Started: "; date; echo -n "Requests : "
  firerequest-macaddr
}

param2POSTmacaddr() {
  PARAMETER="param2"
  COUNT=7000
  URL="http://dvwa.fortinet.demo/param1234.htm"
  METHOD="POST"
  CONTENTTYPE="application/x-www-form-urlencoded"
  echo ""; echo -n "Started: "; date; echo -n "Requests : "
  firerequest-macaddr
}


while true
 do
   initall
   mainmenu
   read_input
   echo ""; echo -n "Ended    : "; date
   pause
done
