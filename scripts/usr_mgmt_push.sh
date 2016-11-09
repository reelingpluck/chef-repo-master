#!/bin/bash

mail_content () {
echo "Please check the details of the $fullname" > data/mail_content
knife data bag show users $username >> data/mail_content
echo "#######################" >> data/mail_content
sed -n '/'`echo $username`'/,/public_ssh_key/p' back_up/ops_users.json >> data/mail_content
}

mail_content

echo "############################################"
echo -e "\e[1;31mPushing the json files to git repo\e[0m"
git checkout pre_develop
git pull origin pre_develop
git status
git add data_bags/users/$username.json data/emails.sh 
git commit -m "Uploading the users and private_keys json files of user $username"
git push origin pre_develop

if [ "$?" -eq 0 ]; then
#git fetch && git log --name-status | grep $username
#git fetch && git log --name-status | grep  ops_users | head -3
echo -e "\e[1;31mFiles are succesfully uploaded to git repo"
else
echo -e "\e[1;31mWe are facing an issue while uploading files to git repo\e[0m"
exit 1
fi
