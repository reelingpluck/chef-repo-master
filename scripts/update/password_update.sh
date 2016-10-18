ops_user_update () {
cat data/$username.yaml >> back_up/ops_users_new.yaml
sed -i '/^$/d' back_up/ops_users_new.yaml
rm -rf data/$username.yaml
yaml-lint back_up/ops_users_new.yaml
if [ $? -eq 0 ]; then
yaml2json back_up/ops_users_new.yaml > data_bags/private_keys/ops_users.json
else
echo -e "\e[1;31mFile is not in valid yaml format, please check\e[0m"
rm -rf data_bags/private_keys/ops_users.json
cp -rf back_up/ops_users.json.bak data_bags/private_keys/ops_users.json
rm -rf back_up/ops_users_new.yaml
exit 1
fi

jsonlint data_bags/private_keys/ops_users.json > /dev/null && grep "$ssh_key" data_bags/private_keys/ops_users.json > /dev/null
if [ $? -eq 0 ]; then
echo -e "\e[1;32mops_users file is sucessfully updated\e[0m"
echo "###########################################"
rm -rf back_up/ops_users_new.yaml
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
rm -rf data_bags/private_keys/ops_users.json
cp -rf back_up/ops_users.json.bak data_bags/private_keys/ops_users.json
rm -rf back_up/ops_users_new.yaml
exit 1
fi
}
echo "###########################################################"
echo -e "\e[1;32mGoing to update the ops_users file\e[0m"
cp -rf data_bags/private_keys/ops_users.json back_up/ops_users.json.bak
sed -n '/'`echo $username`'/,/}/p' data_bags/private_keys/ops_users.json > $username.ops_key
sed  -i  -e '/'`echo $username`'/,/}/d'  data_bags/private_keys/ops_users.json
json2yaml data_bags/private_keys/ops_users.json > back_up/ops_users_new.yaml
if [ $? -ne 0 ]; then
echo -e "\e[1;32mplease check the errors json2yaml\e[0m"
rm -rf data_bags/private_keys/ops_users.json
cp -rf back_up/ops_users.json.bak data_bags/private_keys/ops_users.json
exit 1
fi
echo $username > $username.private
mkpasswd -m sha-512 $password >> $username.private
grep private_key $username.ops_key | cut -d ':' -f2 >> $username.private
echo -e "\e[1;31mCreating the user private key yaml file syntax\e[0m"
IFS=$'\n' read -ra lines -d '' < $username.private
source scripts/update/test_password_yaml.sh "${lines[@]}"
rm -rf $username.private $username.ops_key
echo -e "\e[1;32mValidating the  user private key yaml file syntax\e[0m"
yaml-lint data/$username.yaml
if [ $? -eq 0 ]; then
echo -e "\e[1;32mGenerated users file is in correct yaml format\e[0m"
ops_user_update
else
echo -e "\e[1;31mFile is not in valid yaml format, please check\e[0m"
rm -rf data_bags/private_keys/ops_users.json
rm -rf back_up/ops_users_new.yaml
cp -rf back_up/ops_users.json.bak data_bags/private_keys/ops_users.json
exit 1
fi
