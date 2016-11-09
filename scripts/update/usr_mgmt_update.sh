#!/bin/bash
validation_failure () {
if [ -f back_up/$username.json.bkp ];then 
rm -rf data_bags/users/$username.json
cp -rf back_up/$username.json.bkp data_bags/users/$username.json
fi
}
if [ "$group" != "NA" ];then
echo -e "\e[1;32mGoing to update the group\e[0m"
cp -rf data_bags/users/$username.json back_up/$username.json.bkp && rm -rf data_bags/users/$username.json
sed -n '/{/,/],/p' back_up/$username.json.bkp > data_bags/users/$username.json
sed -i '$d' data_bags/users/$username.json
tail -n 1 data_bags/users/$username.json >  last_line
echo $group | cut -d',' -f1-5 --output-delimiter=$'\n' > $username.groups
while IFS= read -r line
do
    grep $line data_bags/users/$username.json > /dev/null
    if [ $? -eq 0 ]; then
    echo "$line is already existed in your groups list so removing"
    sed -i '/'`echo $line`'/d' $username.groups
    fi
done < $username.groups
sed -i '$d' data_bags/users/$username.json
sed  -e "s/\(.*\)/\"\1\",/" -e 's/^/   /' < $username.groups > $username.groups.bkp && rm -rf $username.groups
cat $username.groups.bkp >> data_bags/users/$username.json
cat last_line >> data_bags/users/$username.json && rm -rf last_line
sed -n '/],/,/{/p'  back_up/$username.json.bkp >> data_bags/users/$username.json
sed -i '/"action"/c\  "action": "update"' data_bags/users/$username.json
while IFS= read -r line
do
    grep $line data_bags/users/$username.json
    if [ $? -eq 0 ]; then
    echo "success" > /dev/null
    else
    exit 1
    fi
done < $username.groups.bkp > /dev/null
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is updated with group name\e[0m"
rm -rf $username.groups.bkp
else
echo -e "\e[1;31mFile is not updated with the group name please check\e[0m"
rm -rf $username.groups.bkp
validation_failure
exit 1
fi
jsonlint data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is in valid json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
validation_failure
exit 1
fi
fi


if [ "$public_ssh_key" != "" ];then
echo -e "\e[1;32mGoing to update the public_ssh_key\e[0m"
cp -rf data_bags/users/$username.json back_up/$username.json.bkp && rm -rf data_bags/users/$username.json
sed -n '/{/,/comment/p'  back_up/$username.json.bkp > data_bags/users/$username.json
echo $username > $username.key
echo $public_ssh_key >> $username.key
IFS=$'\n' read -ra lines -d '' < $username.key
source scripts/templates/usr_mgmt_update_public_ssh_key.template "${lines[@]}"
cat $username.key_temp >> data_bags/users/$username.json
rm -rf  $username.key_temp $username.key
grep "$public_ssh_key" data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is updated with ssh key\e[0m"
else
echo -e "\e[1;31mFile is not updated with the key please check\e[0m"
validation_failure
exit 1
fi
jsonlint data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is in valid json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
validation_failure
exit 1
fi
fi

if [ "$public_ssh_key" != "" ];then
bash scripts/update/usr_mgmt_ops_key_update.sh
fi


if [ "$password" != "" ];then
echo -e "\e[1;32mGoing to update the password\e[0m"
cp -rf data_bags/users/$username.json back_up/$username.json.bkp
sed -i '/"action"/c\  "action": "update"' data_bags/users/$username.json
jsonlint data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is in valid json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
validation_failure
exit 1
fi
bash scripts/update/usr_mgmt_password_update.sh
fi
