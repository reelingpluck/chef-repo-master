#!/bin/bash

rm -rf $WORKSPACE/scripts/mail_content

echo "###########################################"
echo -e "\e[1;31mCreating the databag items for the $username\e[0m"
knife ssl fetch
sleep 5

mail_content () {
echo "Please check the details of the $fullname" > $WORKSPACE/scripts/mail_content
knife data bag show users $username >> $WORKSPACE/scripts/mail_content
echo "#######################" >> $WORKSPACE/scripts/mail_content
knife vault show private_keys ops_users | grep -A 3 $username >> $WORKSPACE/scripts/mail_content
}


if [ -f $WORKSPACE/data_bags/users/$username.json ]; then
echo -e "\e[1;31m Creating the user data bag item for $username\e[0m"
knife data bag from file users $WORKSPACE/data_bags/users/$username.json
else
echo -e "\e[1;31mUsers json file is not found, please recheck\e[0m"
exit 1
fi

if [ -f $WORKSPACE/data_bags/private_keys/ops_users.json ]; then
echo -e "\e[1;31m Updating the ops_users file for user $username\e[0m"
knife vault update private_keys ops_users -A vakkavamsi -M client -S "os:linux" -j $WORKSPACE/data_bags/private_keys/ops_users.json
else
echo -e "\e[1;31mPrivate_key json file is not found, please recheck\e[0m"
exit 1
fi

sleep 10
mail_content

echo -e "\e[1;32mThank you\e[0m"

