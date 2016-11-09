if [ "$ACTION" == "delete" ];then
echo -e "\e[1;32mGoing to delete the user\e[0m"
cp -rf data_bags/users/$username.json back_up/$username.json.bkp
sed -i '/"action"/c\  "action": "delete"' data_bags/users/$username.json
jsonlint data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is in valid json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
rm -rf data_bags/users/$username.json
cp -rf back_up/$username.json.bkp data_bags/users/$username.json
exit 1
fi
cp -rf data_bags/private_keys/ops_users.json back_up/ops_users.json.bkp
sed  -i  -e '/'`echo $username`'/,/}/d'  data_bags/private_keys/ops_users.json
jsonlint data_bags/private_keys/ops_users.json > /dev/null 
if [ $? -eq 0 ]; then
echo -e "\e[1;32mOps file is updated\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
rm -rf data_bags/private_keys/ops_users.json
cp -rf back_up/ops_users.json.bkp data_bags/private_keys/ops_users.json
exit 1
fi
fi
