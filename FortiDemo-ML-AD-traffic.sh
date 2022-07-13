#!/bin/bash

# This script is used to present a menu from which you provide input for FortiWeb Machine Learning traffic generation.
# 2019070301 : Ferry Kemps : Initial release derived from ml-requester.sh FWB Advanced workshop
# 2019070401 : Ferry Kemps : Modified for FortiDemo purposes and new form webpage
# 2019080201 : Ferry Kemps : Changed random character generating due to not ending PIPE via SHELL access
# 2019102201 : Ferry Kemps : Added custom request menu option
# 2019102301 : Ferry Kemps : Date type fix, added date-short/date-long data type, reduced 5.000 request to 3.000
# 2019102302 : Ferry Kemps : Added cmdline options support
  DEBUG="disable"

# Check options given
if [ $# -gt 0 ]; then
   case $1 in
  --debug) DEBUG="enable";;
  --help) echo ""; echo "Usage: ${0} [options...]"
     echo "Options:"
     echo "  --debug		Turn on debug to show requests"
     echo "  --help		Show programm usage"
     echo "";exit;;
  *) echo ""; echo "Usage: ${0} [options...]"
     echo "Options:"
     echo "  --debug		Turn on debug to show requests"
     echo "  --help		Show programm usage"
     echo "";exit;;
esac

   echo "Personal instance identification: ${FPPREPEND}"
   echo "Default product: ${PRODUCT}"
   echo ""
   echo "Usage: gcpcmd.sh [-c configfile] <region> <product> <action>"
   echo "       gcpcmd.sh [-c configfile] [region] [product] list"
   echo "       gcpcmd.sh [-c configfile] [region] [product] listpubip"
   echo "       region  : asia, europe, america"
   echo "       product : fwb, fad, fpx, fsw, fsa, sme, xa, appsec, test"
   echo "       action  : build, start, stop, delete, list, listpubip"
   echo ""
fi

initall() {
  COUNTER=0
  COUNT=0
  RANGE=255
  I=1
  SP=" / - \ |"
  ILLEGALCHARS="[._?&'\" \[]"
  FIRSTNAME="firstname"
  LASTNAME="lastname"
  ADDRESS="address"
  CITY="city"
  STATE="state"
  POSTAL="postal"
  POSTALNUMERIC_LENGTH=4
  POSTALALPHA_LENGTH=2
  COUNTRY="country"
  EMAIL="email"
  FORMID="form_id"
  SUBMIT="submit"
  CONTENTTYPE="application/x-www-form-urlencoded"
  URL="http://finance.fortinet.demo/fwb/index.html"
  USERAGENT="ML-Request-generator"
  REQUESTTIMEOUT=3
}

mainmenu() {
  clear
  echo " ------------------------------------------------------------------------------"
  echo "       FortiDemo Machine Learning Anomaly Detection request generator          "
  echo " ------------------------------------------------------------------------------"
  echo ""
  echo "  1 - 3.000 POST requests - normal field input (learn)"
  echo "  2 - 3.000 POST requests - random field input (relearn)"
  echo "  3 -     1 POST request  - XSS on Lastname field (known attack - Signatures)"
  echo "  4 -     1 POST request  - Exploit on Lastname field (zero day command-injection attack - Machine Learning)"
  echo "  5 -     1 POST request  - Exploit on City field (zero day SQLi attack - Machine Learning)"
  echo ""
  echo "  9 -     Custom request  - Send custom request method, count, data, parameter etc"
  echo ""
  echo "  q - Exit"
  echo ""
}
#  echo "  9 - custom requests, specify amount, URL, method, parameter, data-type"

pause(){
  echo ""
  read -p "Press [Enter] key to continue..." fackEnterKey
}

read_input(){
    local choice
    read -p "Enter choice [ 1 - 9] " choice
    case $choice in
        1) learnparameters ;;
        2) relearnparameters ;;
        3) XSSattack ;;
        4) Exploitattackcmd ;;
        5) Exploitattacksqli ;;
        9) customrequest ;;
        q) exit 0;;
        Q) exit 0;;
        *) echo -e "${RED}Wrong input...${STD}" && sleep 1
    esac
}

firerequest-learn() {
   until [ $COUNTER -eq $COUNT ]
   do
     FIRSTNAME_LENGTH=`shuf -i 4-12 -n 1`
     FIRSTNAMEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z0-9@' | fold -w $FIRSTNAME_LENGTH | head -n 1)
     LASTNAME_LENGTH=`shuf -i 6-25 -n 1`
     LASTNAMEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z0-9-' | fold -w $LASTNAME_LENGTH | head -n 1)
     ADDRESS_LENGTH=`shuf -i 8-22 -n 1`
     ADDRESSVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $ADDRESS_LENGTH | head -n 1)
     ADDRESSNUMBER_LENGTH=`shuf -i 1-5 -n 1`
     ADDRESSNUMBERVALUE=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $ADDRESSNUMBER_LENGTH | head -n 1)
     CITY_LENGTH=`shuf -i 8-30 -n 1`
     CITYVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z0-9-' | fold -w $CITY_LENGTH | head -n 1)
     STATE_LENGTH=`shuf -i 6-14 -n 1`
     STATEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $STATE_LENGTH | head -n 1)
     POSTALNUMERIC=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $POSTALNUMERIC_LENGTH | head -n 1)
     POSTALALPHA=$(head -c400 < /dev/urandom | tr -dc 'A-Z' | fold -w $POSTALALPHA_LENGTH | head -n 1)
     POSTALVALUE=$POSTALNUMERIC$POSTALALPHA
     COUNTRY_LENGTH=`shuf -i 8-18 -n 1`
     COUNTRYVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $COUNTRY_LENGTH | head -n 1)
     FORMID_LENGTH=5
     FORMIDVALUE=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $FORMID_LENGTH | head -n 1)
     SUBMITVALUE="Submit"
     POSTDATA="$FIRSTNAME=$FIRSTNAMEVALUE&$LASTNAME=$LASTNAMEVALUE&$ADDRESS=$ADDRESSVALUE%20$ADDRESSNUMBERVALUE&$CITY=$CITYVALUE&$STATE=$STATEVALUE&$POSTAL=$POSTALVALUE&$COUNTRY=$COUNTRYVALUE&$FORMID=$FORMIDVALUE&$SUBMIT=$SUBMITVALUE"
     webrequest
     sleep 0.01
     let "COUNTER += 1"  # Increment count.
     printprogress $COUNTER
   done
}

firerequest-relearn() {
   until [ $COUNTER -eq $COUNT ]
   do
     FIRSTNAME_LENGTH=`shuf -i 9-22 -n 1`
     FIRSTNAMEVALUE=$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $FIRSTNAME_LENGTH | head -n 1| sed "s/${ILLEGALCHARS}//g")
     LASTNAME_LENGTH=`shuf -i 12-35 -n 1`
     LASTNAMEVALUE=$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $LASTNAME_LENGTH | head -n 1| sed "s/${ILLEGALCHARS}//g")
     ADDRESS_LENGTH=`shuf -i 3-32 -n 1`
     ADDRESSVALUE=$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $ADDRESS_LENGTH | head -n 1| sed "s/${ILLEGALCHARS}//g")
     ADDRESSNUMBER_LENGTH=`shuf -i 4-9 -n 1`
     ADDRESSNUMBERVALUE=$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $ADDRESSNUMBER_LENGTH | head -n 1| sed "s/${ILLEGALCHARS}//g")
     CITY_LENGTH=`shuf -i 8-30 -n 1`
     CITYVALUE=$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $CITY_LENGTH | head -n 1| sed "s/${ILLEGALCHARS}//g")
     STATE_LENGTH=`shuf -i 9-24 -n 1`
     STATEVALUE=$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $STATE_LENGTH | head -n 1| sed "s/${ILLEGALCHARS}//g")
     POSTALNUMERIC=$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $POSTALNUMERIC_LENGTH | head -n 1| sed "s/${ILLEGALCHARS}//g")
     POSTALALPHA=$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $POSTALALPHA_LENGTH | head -n 1| sed "s/${ILLEGALCHARS}//g")
     POSTALVALUE=$POSTALNUMERIC$POSTALALPHA
     COUNTRY_LENGTH=`shuf -i 12-38 -n 1`
     COUNTRYVALUE=$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $COUNTRY_LENGTH | head -n 1| sed "s/${ILLEGALCHARS}//g")
     FORMID_LENGTH=15
     FORMIDVALUE=$(head -c400 < /dev/urandom | tr -dc 'A-Z' | fold -w $FORMID_LENGTH | head -n 1)
     SUBMITVALUE="Submit"
     POSTDATA="$FIRSTNAME=$FIRSTNAMEVALUE&$LASTNAME=$LASTNAMEVALUE&$ADDRESS=$ADDRESSVALUE%20$ADDRESSNUMBERVALUE&$CITY=$CITYVALUE&$STATE=$STATEVALUE&$POSTAL=$POSTALVALUE&$COUNTRY=$COUNTRYVALUE&$FORMID=$FORMIDVALUE&$SUBMIT=$SUBMITVALUE"
     webrequest
     sleep 0.01
     let "COUNTER += 1"  # Increment count.
     printprogress $COUNTER
   done
}

firerequest-XSS() {
   until [ $COUNTER -eq $COUNT ]
   do
     FIRSTNAME_LENGTH=`shuf -i 4-12 -n 1`
     FIRSTNAMEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $FIRSTNAME_LENGTH | head -n 1)
     LASTNAMEVALUE='<script>alert("XSS-hack-attempt")</script>'
     ADDRESS_LENGTH=`shuf -i 8-22 -n 1`
     ADDRESSVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $ADDRESS_LENGTH | head -n 1)
     ADDRESSNUMBER_LENGTH=`shuf -i 1-5 -n 1`
     ADDRESSNUMBERVALUE=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $ADDRESSNUMBER_LENGTH | head -n 1)
     CITY_LENGTH=`shuf -i 8-30 -n 1`
     CITYVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $CITY_LENGTH | head -n 1)
     STATE_LENGTH=`shuf -i 6-14 -n 1`
     STATEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $STATE_LENGTH | head -n 1)
     POSTALNUMERIC=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $POSTALNUMERIC_LENGTH | head -n 1)
     POSTALALPHA=$(head -c400 < /dev/urandom | tr -dc 'A-Z' | fold -w $POSTALALPHA_LENGTH | head -n 1)
     POSTALVALUE=$POSTALNUMERIC$POSTALALPHA
     COUNTRY_LENGTH=`shuf -i 8-18 -n 1`
     COUNTRYVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $COUNTRY_LENGTH | head -n 1)
     FORMID_LENGTH=5
     FORMIDVALUE=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $FORMID_LENGTH | head -n 1)
     SUBMITVALUE="Submit"
     POSTDATA="$FIRSTNAME=$FIRSTNAMEVALUE&$LASTNAME=$LASTNAMEVALUE&$ADDRESS=$ADDRESSVALUE%20$ADDRESSNUMBERVALUE&$CITY=$CITYVALUE&$STATE=$STATEVALUE&$POSTAL=$POSTALVALUE&$COUNTRY=$COUNTRYVALUE&$FORMID=$FORMIDVALUE&$SUBMIT=$SUBMITVALUE"
     webrequest
     sleep 0.01
     let "COUNTER += 1"  # Increment count.
     printprogress $COUNTER
   done
}

firerequest-Exploitcmd() {
   until [ $COUNTER -eq $COUNT ]
   do
     FIRSTNAME_LENGTH=`shuf -i 4-12 -n 1`
     FIRSTNAMEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $FIRSTNAME_LENGTH | head -n 1)
     LASTNAMEVALUE='%X%X%X%X%X%X%X%X%X%X - %X%X%X%X%X%X%X%X%X%X'
     ADDRESS_LENGTH=`shuf -i 8-22 -n 1`
     ADDRESSVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $ADDRESS_LENGTH | head -n 1)
     ADDRESSNUMBER_LENGTH=`shuf -i 1-5 -n 1`
     ADDRESSNUMBERVALUE=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $ADDRESSNUMBER_LENGTH | head -n 1)
     CITY_LENGTH=`shuf -i 8-30 -n 1`
     CITYVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $CITY_LENGTH | head -n 1)
     STATE_LENGTH=`shuf -i 6-14 -n 1`
     STATEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $STATE_LENGTH | head -n 1)
     POSTALNUMERIC=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $POSTALNUMERIC_LENGTH | head -n 1)
     POSTALALPHA=$(head -c400 < /dev/urandom | tr -dc 'A-Z' | fold -w $POSTALALPHA_LENGTH | head -n 1)
     POSTALVALUE=$POSTALNUMERIC$POSTALALPHA
     COUNTRY_LENGTH=`shuf -i 8-18 -n 1`
     COUNTRYVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $COUNTRY_LENGTH | head -n 1)
     FORMID_LENGTH=5
     FORMIDVALUE=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $FORMID_LENGTH | head -n 1)
     SUBMITVALUE="Submit"
     POSTDATA="$FIRSTNAME=$FIRSTNAMEVALUE&$LASTNAME=$LASTNAMEVALUE&$ADDRESS=$ADDRESSVALUE%20$ADDRESSNUMBERVALUE&$CITY=$CITYVALUE&$STATE=$STATEVALUE&$POSTAL=$POSTALVALUE&$COUNTRY=$COUNTRYVALUE&$FORMID=$FORMIDVALUE&$SUBMIT=$SUBMITVALUE"
     webrequest
     sleep 0.01
     let "COUNTER += 1"  # Increment count.
     printprogress $COUNTER
   done
}
firerequest-Exploitsqli() {
   until [ $COUNTER -eq $COUNT ]
   do
     FIRSTNAME_LENGTH=`shuf -i 4-12 -n 1`
     FIRSTNAMEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $FIRSTNAME_LENGTH | head -n 1)
     LASTNAME_LENGTH=`shuf -i 6-25 -n 1`
     LASTNAMEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $LASTNAME_LENGTH | head -n 1)
     ADDRESS_LENGTH=`shuf -i 8-22 -n 1`
     ADDRESSVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $ADDRESS_LENGTH | head -n 1)
     ADDRESSNUMBER_LENGTH=`shuf -i 1-5 -n 1`
     ADDRESSNUMBERVALUE=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $ADDRESSNUMBER_LENGTH | head -n 1)
     CITYVALUE='abc;$compress_message%253dgzcompress("hack%2520message",%252012)'
     STATE_LENGTH=`shuf -i 6-14 -n 1`
     STATEVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $STATE_LENGTH | head -n 1)
     POSTALNUMERIC=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $POSTALNUMERIC_LENGTH | head -n 1)
     POSTALALPHA=$(head -c400 < /dev/urandom | tr -dc 'A-Z' | fold -w $POSTALALPHA_LENGTH | head -n 1)
     POSTALVALUE=$POSTALNUMERIC$POSTALALPHA
     COUNTRY_LENGTH=`shuf -i 8-18 -n 1`
     COUNTRYVALUE=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $COUNTRY_LENGTH | head -n 1)
     FORMID_LENGTH=5
     FORMIDVALUE=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $FORMID_LENGTH | head -n 1)
     SUBMITVALUE="Submit"
     POSTDATA="$FIRSTNAME=$FIRSTNAMEVALUE&$LASTNAME=$LASTNAMEVALUE&$ADDRESS=$ADDRESSVALUE%20$ADDRESSNUMBERVALUE&$CITY=$CITYVALUE&$STATE=$STATEVALUE&$POSTAL=$POSTALVALUE&$COUNTRY=$COUNTRYVALUE&$FORMID=$FORMIDVALUE&$SUBMIT=$SUBMITVALUE"
     webrequest
     sleep 0.01
     let "COUNTER += 1"  # Increment count.
     printprogress $COUNTER
   done
}
customrequest() {
  echo ""
  read -p "Amount of requests: " COUNT
  read -p "URL (http://finance.fortinet.demo/fwb/index.html) " URL
  read -p "Method (GET, POST, PUT, DELETE, OPTIONS, HEAD) : " METHODIN
  read -p "Parameter name : " PARAMETER
  read -p "Parameter type (date-short, date-long, postal, email, phone, random, number-small, number-big) : " PARAMETERTYPE
  echo ""; echo -n "Started  : "; date; echo -n "Requests : "

  METHOD=`echo $METHODIN | tr [:lower:] [:upper:]`

  [ -z $URL ] && URL="http://finance.fortinet.demo/fwb/index.html"
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
    echo "ERROR: Invalid URL given. Use http://<fqdn>/<path>/<object>"
    return
  fi


  until [ $COUNTER -eq $COUNT ]
  do
    if [ $PARAMETERTYPE = "date-short" ]
    then
     temp=$(echo "$RANDOM * $RANDOM * $RANDOM / 1000" | bc -l)
     PARAMETERVALUE=$(date -d @$temp +%d" "%m" "%Y" "%H":"%M":"%S)
    elif [ $PARAMETERTYPE = "date-long" ]
    then
     temp=$(echo "$RANDOM * $RANDOM * $RANDOM / 1000" | bc -l)
     PARAMETERVALUE=$(date -d @$temp)
    elif [ $PARAMETERTYPE = "postal" ]
    then
      POSTALNUMERIC_LENGTH=4
      POSTALALPHA_LENGTH=2
      POSTALNUMERIC=$(head -c400 < /dev/urandom | tr -dc '0-9' | fold -w $POSTALNUMERIC_LENGTH | head -n 1)
      POSTALALPHA=$(head -c400 < /dev/urandom | tr -dc 'A-Z' | fold -w $POSTALALPHA_LENGTH | head -n 1)
      PARAMETERVALUE=$POSTALNUMERIC$POSTALALPHA
    elif [ $PARAMETERTYPE = "email" ]
    then
      EMAILNAME_LENGTH=`shuf -i 4-15 -n 1`
      EMAILDOMAIN_LENGTH=`shuf -i 5-20 -n 1`
      EMAILEXT_LENGTH=`shuf -i 3-4 -n 1`
      USER_NAME=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $EMAILNAME_LENGTH | head -n 1)
      DOMAIN_NAME=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $EMAILDOMAIN_LENGTH | head -n 1)
      DOMAIN_EXT=$(head -c400 < /dev/urandom | tr -dc 'a-zA-Z' | fold -w $EMAILEXT_LENGTH | head -n 1)
      PARAMETERVALUE=$USER_NAME@$DOMAIN_NAME.$DOMAIN_EXT
    elif [ $PARAMETERTYPE = "phone" ]
    then
      COUNTRYCODE=`shuf -i 1-99 -n 1`
      AREAPHONE=`shuf -i 100000000-999999999 -n 1`
      PARAMETERVALUE="%2B$COUNTRYCODE-$AREAPHONE"
    elif [ $PARAMETERTYPE = "random" ]
    then
      RANDOM_LENGTH=15
      PARAMETERVALUE="$(head -c400 < /dev/urandom | tr -dc [:print:] | fold -w $RANDOM_LENGTH | head -n 1| sed s/[\?\&]//g)"
    elif [ $PARAMETERTYPE = "number-small" ]
    then
      PARAMETERVALUE=`shuf -i 0-100 -n 1`
    elif [ $PARAMETERTYPE = "number-big" ]
    then
      PARAMETERVALUE=`shuf -i 1000-10000000 -n 1`
    else
      echo "ERROR: no valid data type"
      return
    fi

    [ ${DEBUG} == "enable" ] && echo "Method="${METHOD} "URL="${URL} "Paremeter="${PARAMETER} "Value="${PARAMETERVALUE}

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

webrequest() {
  [ ${DEBUG} == "enable" ] && echo "URL:"${URL} "POSTDATA":${POSTDATA}
  curl -A ${USERAGENT} -m ${REQUESTTIMEOUT} -g --retry 3 --retry-delay 1 -s -o /dev/null -X ${METHOD} -H "Content-Type: ${CONTENTTYPE}" "${URL}" -d "$POSTDATA" &
}

learnparameters() {
  COUNT=3000
  METHOD="POST"
  echo ""; echo -n "Started: "; date; echo -n "Requests : "
  firerequest-learn
  echo ""; echo -n "Ended    : "; date
}

relearnparameters() {
  COUNT=3000
  METHOD="POST"
  echo ""; echo -n "Started: "; date; echo -n "Requests : "
  firerequest-relearn
  echo ""; echo -n "Ended    : "; date
}

XSSattack() {
  COUNT=1
  METHOD="POST"
  echo ""; echo -n "Started: "; date; echo -n "Requests : "
  firerequest-XSS
  echo ""; echo -n "Ended    : "; date
}

Exploitattackcmd() {
  COUNT=1
  METHOD="POST"
  echo ""; echo -n "Started: "; date; echo -n "Requests : "
  firerequest-Exploitcmd
  echo ""; echo -n "Ended    : "; date
}

Exploitattacksqli() {
  COUNT=1
  METHOD="POST"
  echo ""; echo -n "Started: "; date; echo -n "Requests : "
  firerequest-Exploitsqli
  echo ""; echo -n "Ended    : "; date
}

while true
 do
   initall
   mainmenu
   read_input
   pause
done
