#echo "############################################"
echo -e "\e[1;31mPushing the json files to git repo\e[0m"
git checkout develop
git status
git add .
git commit -m "Uploading the users and private_keys json files of user $username"
git pull origin develop
git push origin develop

if [ "$?" -eq 0 ]; then
git fetch && git log --name-status | grep $username
git fetch && git log --name-status | grep  ops_users | head -3
echo -e "\e[1;31mFiles are succesfully uploaded to git repo"
else
echo -e "\e[1;31mWe are facing an issue while uploading files to git repo\e[0m"
exit 1
fi
