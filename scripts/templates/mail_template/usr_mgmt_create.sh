#!/bin/bash
echo "#######################################################################"
echo  -e "\e[1;31mPlease check the details provided\e[0m"
echo  -e "Your username is \e[1;34m$username\e[0m"
echo  -e "Your fullname is \e[1;33m$fullname\e[0m"
echo  -e "Your e-mail address is \e[1;32m$email\e[0m"
echo  -e "Your group name is \e[1;36m$group\e[0m"
echo  -e "Your ssh_key is \e[1;34m$ssh_key\e[0m"
echo  -e "Action Item is  \e[1;34m$ACTION\e[0m"
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

echo -e "\e[1;31mVerifying the e-mail id\e[0m"
verify_email

current_user=$( get_user )
grep $email data/emails.sh > /dev/null

if [ $? -eq 0 ]; then
  echo -e "\e[1;31mMailid $email is already exists with the $current_user\e[0m"
  exit 1
fi

if [ -z "$username" ]; then
  echo -e "\033[1;31mPlease provide the username\e[0m"
  exit 1
elif [ -f data_bags/users/$username.json ]; then
  echo -e "\e[1;31m$username.json already exists\e[0m"
  exit 1
else
  echo $username > $username.content
  echo "$username:$email" >> data/emails.sh
fi

if [ -z "$fullname" ]; then
  echo -e "\033[1;31mPlease provide the fullname\e[0m"
  exit 1
else
  echo $fullname >> $username.content
  echo $email >> $username.content
fi

if [ -z "$group" ]; then
  echo -e "\033[1;31mPlease provide the groupname\e[0m"
  exit 1
fi

## TODO: Why are we limiting the user to 5 groups? ##
i=`echo $group | cut -d',' -f1-5 --output-delimiter=$'\n' | wc -l` 
if [ $i -ge 5 ];then
  echo -e "\e[1;31mPlease provide five or below group names\e[0m"
  exit 1
else
  echo $group  >> $username.content
fi
#################################################

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
source scripts/templates/mail_template/mail_template.html "${arr[@]}"
rm -rf $username.content
