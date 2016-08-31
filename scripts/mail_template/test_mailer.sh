#!/bin/bash
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
suffix=$( echo "$email" | cut -d '@' -f2 )
if [[ "$suffix" == "itaas.com" || "$suffix" == "dimensiondata.com" || "$suffix" == "itaas.dimensiondata.com" ]]; then
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
grep -w $email < data/emails.sh | cut -d ':' -f1
}
current_user=$( get_user )
grep $email data/emails.sh > /dev/null
if [ $? -eq 0 ]; then
echo -e "\e[1;31mMailid $email is already exists with the $current_user\e[0m"
exit 1
fi
if [ "$username" == "" ]; then
echo -e "\033[1;31mPlease provide the username\e[0m"
exit 1
elif [ -f data_bags/users/$username.json ]; then
echo -e "\e[1;31mFile already exists\e[0m"
exit 1
else
echo $username > $username.content
echo "$username:$email" >> data/emails.sh
fi
if [ "$fullname" == "" ]; then
echo -e "\033[1;31mPlease provide the fullname\e[0m"
exit 1
else
echo $fullname >> $username.content
echo $email >> $username.content
fi
highest_uid () {
  grep "uid" data_bags/users/*.json |awk '{print $3}' |sort -n |awk  END{print} |cut -d, -f1 |tr -d '"'
}
current_user_uid=$[`highest_uid`+1]
echo $current_user_uid >> $username.sh
if [ "$group" == "" ]; then
echo -e "\033[1;31mPlease provide the groupname\e[0m"
exit 1
else
echo $group >> $username.content
fi
if [ "$ssh_key" == "" ]; then
echo -e "\033[1;31mPlease provide the ssh_key\e[0m"
exit 1
else
echo $ssh_key >> $username.content
fi
echo -e "\e[1;31mGenerating the mail content\e[0m"
IFS=$'\n' read -ra arr -d '' < $username.content
source scripts/mail_template/mail_template.html "${arr[@]}"
rm -rf $username.content
