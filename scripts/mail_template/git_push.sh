#echo "############################################"
#echo -e "\e[1;31mPushing the json files to git repo\e[0m"
git checkout test
git status
git add .
git commit -m "Uploading the temp files of user $username"
git pull origin test
git push origin test

if [ "$?" -eq 0 ]; then
echo -e "\e[1;31mFiles are succesfully uploaded to git repo"
else
echo -e "\e[1;31mWe are facing an issue while uploading files to git repo\e[0m"
exit 1
fi
