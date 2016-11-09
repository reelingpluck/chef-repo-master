#!/bin/bash
#This script checks the existing and new users information and execute the tasks based upon the conditions.This script will create the json files and validate tje syntax also.
rm -rf data_bags/private_keys/data/ops_users.json.bkp
highest_uid () {
  grep "uid" data_bags/users/*.json |awk '{print $3}' |sort -n |awk  END{print} |cut -d, -f1 |tr -d '"'
}
current_user_uid=$[`highest_uid`+1]
echo $username > $username.sh
echo $fullname >> $username.sh
echo $current_user_uid >> $username.sh
echo $public_ssh_key > $username.ssh
echo $public_ssh_key >> $username.sh
echo $group | cut -d',' -f1-5 --output-delimiter=$'\n' >> $username.sh
group_change () {
#i=`echo $group | cut -d',' -f1-5 --output-delimiter=$'\n' | wc -l`
bash scripts/templates/usr_mgmt_group.template  > scripts/templates/test_user_add_bak.sh
}
group_change
validation_failure () {
grep -wv "$email"  data/emails.sh > data/emails.sh.new && mv data/emails.sh.new data/emails.sh
rm -rf data_bags/users/$username.json
}
echo "###########################################################"
echo -e "\e[1;31mCreating the users json file\e[0m"
IFS=$'\n' read -ra arr -d '' < $username.sh
source scripts/templates/test_user_add_bak.sh "${arr[@]}"
rm -rf $username.sh
rm -rf scripts/templates/test_user_add_bak.sh
echo "##########################################################"
echo -e "\e[1;32mValidating the user json file syntax\e[0m"
jsonlint data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mCreating the databag items for the $username\e[0m"
knife ssl fetch
sleep 5
knife data bag from file users data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32m Please check the content of  user data bag item for $username\e[0m"
knife data bag show users $username
else
echo -e "\e[1;31m Facing issue in creating the data bag item for user, please check\e[0m"
validation_failure
exit 1
fi
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
validation_failure
exit 1
fi
private_key_json () {
echo $username > $username.private
mkpasswd -m sha-512 $password >> $username.private
#cat $username.ssh | md5sum > $username.md5
#cut -d ' ' -f1 < $username.md5 >> $username.private
#rm -rf $username.md5
cat $username.ssh >> $username.private
}
private_key_json
ops_user_update () {
echo -e "\e[1;32mUpdating ops_users file for the user $fullname\e[0m"
IFS=$'\n' read -ra arr -d '' < $username.private
source scripts/templates/usr_mgmt_vault_update.template "${arr[@]}"
rm -rf $username.private
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
cat back_up/ops_users.json | grep $username > /dev/null
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











