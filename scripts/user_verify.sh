#!/bin/bash
#This script checks the existing and new users information and execute the tasks based upon the conditions.This script will create the json files and validate tje syntax also.
rm -rf data_bags/private_keys/ops_users_temp.json
rm -rf $username.temp/$username.html
validation_failure () {
grep -wv "$email"  data/emails.sh > data/emails.sh.new && mv data/emails.sh.new data/emails.sh
rm -rf data_bags/users/$username.json
rm -rf data_bags/private_keys/$username.yaml
}
echo "###########################################################"
echo -e "\e[1;31mCreating the users json file\e[0m"
IFS=$'\n' read -ra arr -d '' < $username.temp/$username.sh
source scripts/test_user_add.sh "${arr[@]}"
rm -rf $username.temp/$username.sh
echo "##########################################################"
echo -e "\e[1;32mValidating the user json file syntax\e[0m"
jsonlint data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mGenerated users file is in correct json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
validation_failure
exit 1
fi
private_key_json () {
echo $username > $username.temp/$username.private
cat $username.temp/$username.ssh | md5sum > $username.temp/$username.md5
cut -d ' ' -f1 < $username.temp/$username.md5 >> $username.temp/$username.private
rm -rf $username.temp/$username.md5
cat $username.temp/$username.ssh >> $username.temp/$username.private
}
private_key_json
ops_user_update () {
cat data/$username.yaml >> data/ops_users_new.yaml 
yaml-lint data/ops_users_new.yaml
if [ $? -eq 0 ]; then
cp data_bags/private_keys/ops_users.json data/ops_users_bkp.json && rm -rf data_bags/private_keys/ops_users.json
yaml2json data/ops_users_new.yaml > data_bags/private_keys/ops_users.json
cp data_bags/private_keys/ops_users.json data_bags/private_keys/ops_users_temp.json && sed -i 's/ops_users/ops_users_temp/g' data_bags/private_keys/ops_users_temp.json
jsonlint data_bags/private_keys/ops_users.json > /dev/null
if [ $? -eq 0 ]; then
echo -e "\e[1;32mops_users file is successfully updated and please check the contents of the $fullname\e[0m"
jsonlint data_bags/users/$username.json
echo "###########################################"
cat data/$username.yaml
rm -rf data/$username.yaml
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
exit 1
fi
else
echo -e "\e[1;31mFile is not in valid yaml format, please check\e[0m"
exit 1
fi
}
echo "###########################################################"
echo -e "\e[1;31mCreating the user private key yaml file syntax\e[0m"
IFS=$'\n' read -ra lines -d '' < $username.temp/$username.private
source scripts/test_user_yaml.sh "${lines[@]}"
rm -rf $username.temp/$username.private $username.temp/$username.ssh
echo -e "\e[1;32mValidating the  user private key yaml file syntax\e[0m"
yaml-lint data/$username.yaml
if [ $? -eq 0 ]; then
echo -e "\e[1;32mGenerated users file is in correct yaml format\e[0m"
ops_user_update
else
echo -e "\e[1;31mFile is not in valid yaml format, please check\e[0m"
validation_failure
exit 1
fi
