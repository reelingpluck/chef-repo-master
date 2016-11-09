#!/bin/bash
echo "#######################################################################"
echo  -e "\e[1;31myou requested to update your content\e[0m"
echo  -e "Your username is \e[1;34m$username\e[0m"
#echo -e "Your Fullname is \e[1;33m$fullname\e[0m"
#echo  -e "Your emailid is \e[1;32m$email\e[0m"
#echo  -e "Your group name is \e[1;36m$group\e[0m"
#echo  -e "Your ssh_key is \e[1;34m$ssh_key\e[0m"
echo "#######################################################################"

# Load common.sh for common used functions
if [ -f scripts/mail_template/common.sh ]; then
  source scripts/mail_template/common.sh
else
  echo "Missing common.sh, exiting"
  exit 1
fi

if [ -z "$email" ]; then
  echo -e "\033[1;31mPlease provide the email\e[0m"
  exit 1
fi

echo -e "\e[1;31mVerifying the maild id\e[0m"
verify_email

current_user=$( get_user )
grep $email data/emails.sh > /dev/null

if [ $? -eq 0 ]; then
  echo -e "\e[1;31mMailid $email is  exists with the $current_user\e[0m"
else
  echo -e "\e[1;31m$username is not in our data base please use the create option\e[0m"
  exit 1
fi

if [ -z "$username" ]; then
  echo -e "\033[1;31mPlease provide the username\e[0m"
  exit 1
else
  echo $username > $username.content
fi

if [ -z "$fullname" ]; then
  echo -e "\033[1;31mPlease provide the fullname\e[0m"
  exit 1
else
  echo $fullname >> $username.content
  echo $email >> $username.content
fi

if [ !-z "$group" ]; then
  i=`echo $group | cut -d',' -f1-5 --output-delimiter=$'\n' | wc -l`
  if [ $i -ge 5 ]; then
    echo -e "\e[1;31mPlease provide five or below group names\e[0m"
    exit 1
  else
  echo $group  >> $username.content
  fi
else
  echo "NA" >> $username.content
fi

if [ -z "$group" ] && [ -z "$password" ] && [ -z "$ssh_key" ]; then
  echo -e "\e[1;31mPlease specify atleast one option(group, ssh_key or password) to update\e[0m"
  exit 1
else
  for var in group password ssh_key; do
    if [ "${!var}" != '' ]; then 
      echo "going to update the $var contents"
    fi
  done
fi

if [ -z "$ssh_key" ]; then
  echo "NA" >> $username.content
else
  echo $ssh_key >> $username.content
fi
if [ -z "$password" ]; then
  echo "NA" >> $username.content
else
  echo $password >> $username.content
fi
echo $ACTION >> $username.content
echo -e "\e[1;31mGenerating the mail content\e[0m"
IFS=$'\n' read -ra arr -d '' < $username.content
source scripts/mail_template/mail_template.html "${arr[@]}"
rm -rf $username.content
