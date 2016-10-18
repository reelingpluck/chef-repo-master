#!/bin/sh
rm -rf data_bags/private_keys/data/ops_users_bkp.json
if [ "$group" != "" ];then
echo -e "\e[1;32mGoing to update the group\e[0m"
cp -rf data_bags/users/$username.json back_up/$username.json.bak && rm -rf data_bags/users/$username.json
sed -n '/{/,/],/p' back_up/$username.json.bak > data_bags/users/$username.json
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
sed  -e "s/\(.*\)/\"\1\",/" -e 's/^/   /' < $username.groups > $username.groups.bak && rm -rf $username.groups
cat $username.groups.bak >> data_bags/users/$username.json
cat last_line >> data_bags/users/$username.json && rm -rf last_line
sed -n '/],/,/{/p'  back_up/anilpill.json.bak >> data_bags/users/$username.json
sed -i '/"action"/c\  "action": "update"' data_bags/users/$username.json
while IFS= read -r line
do
    grep $line data_bags/users/$username.json
    if [ $? -eq 0 ]; then
    echo "success" > /dev/null
    else
    exit 1
    fi
done < $username.groups.bak > /dev/null
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is updated with group name\e[0m"
rm -rf $username.groups.bak
else
echo -e "\e[1;31mFile is not updated with the group name please check\e[0m"
rm -rf data_bags/users/$username.json
rm -rf $username.groups.bak
cp -rf back_up/$username.json.bak data_bags/users/$username.json
exit 1
fi
jsonlint data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is in valid json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
rm -rf data_bags/users/$username.json
cp -rf back_up/$username.json.bak data_bags/users/$username.json
exit 1
fi
fi


if [ "$ssh_key" != "" ];then
echo -e "\e[1;32mGoing to update the ssh_key\e[0m"
cp -rf data_bags/users/$username.json back_up/$username.json.bak && rm -rf data_bags/users/$username.json
sed -n '/{/,/comment/p'  back_up/$username.json.bak > data_bags/users/$username.json
echo $username > $username.key
echo $ssh_key >> $username.key
IFS=$'\n' read -ra lines -d '' < $username.key
source update/ssh_key.template "${lines[@]}"
cat $username.key_temp >> data_bags/users/$username.json
rm -rf  $username.key_temp $username.key
grep "$ssh_key" data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is updated with ssh key\e[0m"
else
echo -e "\e[1;31mFile is not updated with the key please check\e[0m"
rm -rf data_bags/users/$username.json
cp -rf back_up/$username.json.bak data_bags/users/$username.json
exit 1
fi
jsonlint data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is in valid json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
rm -rf data_bags/users/$username.json
cp -rf back_up/$username.json.bak data_bags/users/$username.json
exit 1
fi
fi

if [ "$ssh_key" != "" ];then
sh scripts/update/ops_key_update.sh
fi


if [ "$password" != "" ];then
echo -e "\e[1;32mGoing to update the password\e[0m"
cp -rf data_bags/users/$username.json back_up/$username.json.bak
sed -i '/"action"/c\  "action": "update"' data_bags/users/$username.json
jsonlint data_bags/users/$username.json
if [ $? -eq 0 ]; then
echo -e "\e[1;32mUser file is in valid json format\e[0m"
else
echo -e "\e[1;31mFile is not in valid json format, please check\e[0m"
rm -rf data_bags/users/$username.json
cp -rf back_up/$username.json.bak data_bags/users/$username.json
exit 1
fi
sh scripts/update/password_update.sh
fi
