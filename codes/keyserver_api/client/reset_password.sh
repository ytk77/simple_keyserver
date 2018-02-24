#!/bin/bash

NEW_PW=`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1`
echo $NEW_PW
## save new password to a backup file
echo $NEW_PW > ~/.newpassword

## send new password to server
ACCESS="${HOSTNAME}_`whoami`"
IP=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
VALUE="${IP}___`whoami`___${NEW_PW}"
echo $ACCESS
echo $VALUE
## encrypt value
CIPHERTEXT=`Rscript encrypt_msg.R $VALUE`
echo $CIPHERTEXT

cmd="curl \"http://ip.of.keyserver:9000/newpassword?access=${ACCESS}&value=${CIPHERTEXT}&token=52d7ef4ee01e2c2c75bff572f957cd4f12d6225eee07ea2f01d02b\" "
echo $cmd
RES=`eval ${cmd}`
echo $RES

# IF success, reset with the password
if [[ $RES = *"done"* ]]
then
	echo `whoami`:$NEW_PW | sudo chpasswd
	echo "Successfully reset password"
fi
