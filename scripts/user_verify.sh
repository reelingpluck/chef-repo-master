#!/bin/bash

#This script checks the existing and new users information and execute the tasks based upon the conditions.This script will create the json files and validate tje syntax also.

echo "#######################################################################"
echo  -e "\e[1;31mPlease check the details provided\e[0m"
echo  -e "Your username is \e[1;34m$username\e[0m"
echo -e "Your Fullname is \e[1;33m$fullname\e[0m"
echo  -e "Your emailid is \e[1;32m$email\e[0m"
echo  -e "Your group name is \e[1;36m$group\e[0m"
echo  -e "Your ssh_key is \e[1;34m$ssh_key\e[0m"
echo "#######################################################################"

#This verify_email section will map the users name with mail id's to avoid the duplicate entries in future.
verify_email () {
prefix=$( echo "$email" | cut -d '@' -f2 )
#echo "$prefix"
if [[ "$prefix" == "itaas.com" || "$prefix" == "dimensiondata.com" || "$prefix" == "itaas.dimensiondata.com" ]]; then
echo "You have provided the offical mail id"
else
echo -e "\e[1;31myour maild is not in the correct format, Please provide your offical mail id\e[0m"
exit 1
fi
}

if [ "$email" == "" ]; then
echo -e "\033[1;31mPlease provide the email\e[0m"
exit 1
fi

echo -e "\e[1;31mVerifying the maild id\e[0m"
verify_email

get_user () {
grep -w $email < $WORKSPACE/scripts/emails.sh | cut -d ':' -f1
}
current_user=$( get_user )


grep $email $WORKSPACE/scripts/emails.sh > /dev/null    
if [ $? -eq 0 ]; then
echo -e "\e[1;31mMailid $email is already exists with the $current_user\e[0m"
exit 1
fi

if [ "$username" == "" ]; then
echo -e "\033[1;31mPlease provide the username\e[0m"
exit 1
elif [ -f $WORKSPACE/data_bags/users/$username.json ]; then
echo -e "\e[1;31mFile already exists\e[0m"
exit 1
else
echo $username > $WORKSPACE/$username.sh
#echo $email >> $username.sh
echo "$username:$email" >> $WORKSPACE/scripts/emails.sh
fi


if [ "$fullname" == "" ]; then
echo -e "\033[1;31mPlease provide the fullname\e[0m"
exit 1
else
echo $fullname >> $WORKSPACE/$username.sh
fi

highest_uid () {
  #export high_uid=`grep "uid" ~/chef-repo_didata/data_bags/users/*.json |awk '{print $3}' |sort -n |awk  END{print} |cut -d, -f1`
  grep "uid" $WORKSPACE/data_bags/users/*.json |awk '{print $3}' |sort -n |awk  END{print} |cut -d, -f1 |tr -d '"'
}

current_user_uid=$[`highest_uid`+1]
echo $current_user_uid >> $WORKSPACE/$username.sh
 
if [ "$group" == "" ]; then
echo -e "\033[1;31mPlease provide the groupname\e[0m"
exit 1
else
echo $group >> $WORKSPACE/$username.sh
fi

if [ "$ssh_key" == "" ]; then
echo -e "\033[1;31mPlease provide the ssh_key\e[0m"
exit 1
else 
echo $ssh_key > $WORKSPACE/$username.ssh
fi

echo "###########################################################"
echo -e "\e[1;31mCreating the users json file\e[0m"
IFS=$'\n' read -ra arr -d '' < $WORKSPACE/$username.sh
source $WORKSPACE/scripts/test_user_add.sh "${arr[@]}"
rm -rf $WORKSPACE/$username.sh

#Please go through the below link to know more details about this section.
#https://github.com/zaach/jsonlint

echo "##########################################################"
echo -e "\e[1;32mValidating the user json file syntax\e[0m"
jsonlint $WORKSPACE/data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mGenerated users file is in correct json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
exit 1
fi

echo "###########################################################"
echo -e "\e[1;31mCreating the user private key json file syntax\e[0m"

private_key_json () {
echo $username > $WORKSPACE/$username.private
cat $WORKSPACE/$username.ssh | md5sum > $WORKSPACE/$username.md5
cut -d ' ' -f1 < $WORKSPACE/$username.md5 >> $WORKSPACE/$username.private
rm -rf $WORKSPACE/$username.md5
#tail -n +2 $WORKSPACE/$username.ssh | head -n -1 > $WORKSPACE/$username.ssh.new && mv $WORKSPACE/$username.ssh.new $WORKSPACE/$username.ssh
#tr '\n' ' ' < $WORKSPACE/$username.ssh > $WORKSPACE/$username.ssh.new && mv $WORKSPACE/$username.ssh.new $WORKSPACE/$username.ssh
cat $WORKSPACE/$username.ssh >> $WORKSPACE/$username.private
}
private_key_json

IFS=$'\n' read -ra lines -d '' < $WORKSPACE/$username.private
#source reddy.sh $arguments
source $WORKSPACE/scripts/test_user_private_add.sh "${lines[@]}"
rm -rf $username.private $username.ssh

echo "#############################################################"
echo -e "\e[1;32mValidating the  user private key json file syntax\e[0m"
jsonlint $WORKSPACE/data_bags/private_keys/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mGenerated users file is in correct json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
exit 1
fi

