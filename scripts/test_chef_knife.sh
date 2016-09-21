#!/bin/bash

rm -rf data/mail_content

echo "###########################################"
echo -e "\e[1;31mCreating the databag items for the $username\e[0m"
knife ssl fetch
sleep 5

mail_content () {
echo "Please check the details of the $fullname" > data/mail_content
knife data bag show users $username >> data/mail_content
echo "#######################" >> data/mail_content
knife vault show private_keys ops_users_temp | grep -A 3 $username >> data/mail_content
}


if [ -f data_bags/users/$username.json ]; then
echo -e "\e[1;31m Creating the user data bag item for $username\e[0m"
knife data bag from file users data_bags/users/$username.json
if [ $? -ne 0 ]; then
exit 1
fi
else
echo -e "\e[1;31mUsers json file is not found, please recheck\e[0m"
exit 1
fi

if [ -f data_bags/private_keys/ops_users_temp.json ]; then
echo -e "\e[1;31m Updating the ops_users file for user $username\e[0m"
knife vault update private_keys ops_users_temp -A ngupta -M client -S "os:linux" -j data_bags/private_keys/ops_users_temp.json
if [ $? -ne 0 ]; then
exit 1
fi
else
echo -e "\e[1;31mPrivate_key json file is not found, please recheck\e[0m"
exit 1
fi

sleep 10
mail_content

echo -e "\e[1;32mThank you\e[0m"

