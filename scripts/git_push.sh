#echo "############################################"
echo -e "\e[1;31mPushing the json files to git repo\e[0m"
git checkout test
git status
git add $WORKSPACE/scripts/emails.sh $WORKSPACE/data_bags/users/$username.json $WORKSPACE/data_bags/private_keys/$username.json
git commit -m "Uploading the users and private_keys json files of user $username"
git pull origin test
git push origin test

if [ "$?" -eq 0 ]; then
echo -e "\e[1;31mFiles are succesfully uploaded to git repo"
git fetch && git log --name-status | grep $username
else
echo -e "\e[1;31mWe are facing an issue while uploading files to git repo\e[0m"
exit 1
fi
