#! /bin/bash

# functions
function startmsg {
       	echo -n " "$1"...."
}

function endmsg {
       	echo "done"
}

# variables
FORTIPOCIP="10.2.2.254"
FORTIPOCDIR="static/docs/latest"
LOGFILE=/tmp/lubuntu-setup-$$.log

# Populate hosts file so we can use FQDN's instead of IP-addresses
startmsg "Populating /etc/hosts file"
cat << EOF >> /etc/hosts
10.2.2.100 unprotected.fortinet.demo bricks.fortinet.demo bwapp.fortinet.demo
10.2.2.101 protected.fortinet.demo
10.2.2.201 dvwa.fortinet.demo
10.2.2.202 finance.fortinet.demo
EOF
endmsg

# Set Lubuntu password so you can SSH into Lubuntu
startmsg "Setting lubuntu user pwd"
/usr/bin/passwd lubuntu << EOF > /tmp/passwd 2>&1
fortinet
fortinet
EOF
endmsg

# Disabling X11 screensaver to reduce network load
startmsg "Disabling screensaver"
sudo wget http://${FORTIPOCIP}/${FORTIPOCDIR}/config/xscreensaver -O /home/lubuntu/.xscreensaver > /dev/null 2>&1
endmsg

# Installing AttackSamplest.txt file on Desktop
startmsg "Installing AttackSamples.txt onto Desktop"
sudo wget http://${FORTIPOCIP}/${FORTIPOCDIR}/AttackSamples.txt -O ~lubuntu/Desktop/AttackSamples.txt > /dev/null 2>&1
endmsg

# Downloading FortiWeb Machine Learning request generators
startmsg "Downloading FortiWeb Machine Learning request generators"
sudo wget http://${FORTIPOCIP}/${FORTIPOCDIR}/ml-requests.sh -O ~lubuntu/ml-requests.sh > /dev/null 2>&1
sudo chmod +x ~lubuntu/ml-requests.sh
sudo wget http://${FORTIPOCIP}/${FORTIPOCDIR}/FortiDemo-ML-AD-traffic.sh -O ~lubuntu/FortiDemo-ML-AD-traffic.sh > /dev/null 2>&1
sudo chmod +x ~lubuntu/FortiDemo-ML-AD-traffic.sh
sudo wget http://${FORTIPOCIP}/${FORTIPOCDIR}/bot-simulator.sh -O ~lubuntu/bot-simulator.sh > /dev/null 2>&1
sudo chmod +x ~lubuntu/bot-simulator.sh
sudo wget http://${FORTIPOCIP}/${FORTIPOCDIR}/api-legit.sh -O ~lubuntu/api-legit.sh > /dev/null 2>&1
sudo chmod +x ~lubuntu/api-legit.sh
sudo wget http://${FORTIPOCIP}/${FORTIPOCDIR}/api-get.sh -O ~lubuntu/api-get.sh > /dev/null 2>&1
sudo chmod +x ~lubuntu/api-get.sh
endmsg

cat << EOF > ~lubuntu/generate-to-bricks.sh
#!/bin/bash

# Definitions
URL="http://protected.fortinet.demo/content-1/index.php"
PARAMNAME="id"
COUNT=1000
COUNTER=1
METHOD="GET" # Specify either GET, POST or PUT
# No need to edit below this line
i=1
sp="/ - \ | "

echo "Generating Machine Learning traffic"
echo "URL       : \$URL"
echo "Requests  : \$COUNT"
echo "Parameter : \$PARAMNAME"
echo "Method    : \$METHOD"

until [ \$COUNTER -gt \$COUNT ]
  do
    PARAMVALUE=\`shuf -i 1-3 -n 1\`
    let COUNTER=COUNTER+1
    [ \$METHOD == GET ]  && wget -U ML-generator --delete-after -q "\$URL?\$PARAMNAME=\$PARAMVALUE"
    [ \$METHOD == POST ] && wget -U ML-generator --delete-after -q --post-data=\$PARAMNAME=\$PARAMVALUE "\$URL"
    [ \$METHOD == PUT ]  && wget -U ML-generator --delete-after -q --method=PUT "$URL?\$PARAMNAME=\$PARAMVALUE"
    printf "\b\${sp:i++%\${#sp}:1}"
done
echo ""; echo "done"
EOF
chmod +x ~lubuntu/generate-to-bricks.sh
chown lubuntu:lubuntu ~lubuntu/generate-to-bricks.sh

# Install some additional packages
echo "*** You can continue with the workshop while the package installation finishes in the background ***"
startmsg "Installing additional packages"
sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq curl ssh florence > /dev/null 2>&1
endmsg
