#!/bin/bash
validation_failure () {
if [ -f back_up/$username.json.bkp ];then
rm -rf data_bags/users/$username.json
cp -rf back_up/$username.json.bkp data_bags/users/$username.json
fi
}

ops_user_update () {
knife vault show private_keys_develop ops_users > back_up/ops_users.json
echo $username > back_up/$username.ops_password
mkpasswd -m sha-512 $password > verify_password
cat verify_password >> back_up/$username.ops_password
sed -n '/'`echo $username`'/,/private_key/p' back_up/ops_users.json | grep public_ssh_key | cut -d ':' -f2 >> back_up/$username.ops_password
sed -i 's/^ *//g' back_up/$username.ops_ssh_key
echo -e "\e[1;32mUpdating ops_users file for the user $fullname\e[0m"
IFS=$'\n' read -ra arr -d '' < $username.ops_password
source scripts/templates/usr_mgmt_vault_update.template "${arr[@]}"
rm -rf $username.ops_password
jsonlint back_up/$username.vaultitem
if [ $? -eq 0 ]; then
echo -e "\e[1;32mGenerating the vault item for the $username\e[0m"
knife vault update private_keys_develop ops_users -J back_up/$username.vaultitem
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
validation_failure
exit 1
fi
sleep 20
echo "##########################################################"
echo -e "\e[1;32mChecking the $username content in ops_users file\e[0m"
knife vault show private_keys_develop ops_users > back_up/ops_users.json
cat back_up/ops_users.json | grep `cat verify_password` > /dev/null
if [ $? -eq 0 ]; then
echo -e "\e[1;32m$username data is updated in ops_users file\e[0m"
sed -n '/'`echo $username`'/,/public_ssh_key/p' back_up/ops_users.json
else
echo -e "\e[1;31mops_users file is not updated with $username content please check\e[0m"
validation_failure
exit 1
fi
}
ops_user_update






































