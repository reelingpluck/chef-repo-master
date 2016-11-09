#!/bin/bash

highest_uid () {
  #export high_uid=`grep "uid" ~/chef-repo_didata/data_bags/users/*.json |awk '{print $3}' |sort -n |awk  END{print} |cut -d, -f1`
  grep "uid" ~/chef-repo_didata/data_bags/users/*.json |awk '{print $3}' |sort -n |awk  END{print} |cut -d, -f1 |tr -d '"'
}

echo "Enter Username and press [ENTER]"
read username
echo "Enter Full Name and press [ENTER]"
read fullname
echo "Enter UID and press [ENTER] (Next available UID is $[`highest_uid`+1])"
read uid
echo "Enter group association (default is 'user' for everyone)"
read group 
echo "Enter ssh string and press [ENTER]"
read sshstring

cat << EOF > ~/chef-repo_didata/data_bags/users/$username.json
{
  "id": "$username",
  "uid": "$uid",
  "groups": [
    "$group",
    "users"
  ],
  "shell": "/bin/bash",
  "home_dir": "/home/$username",
  "comment": "$fullname",
  "ssh_keys": "$sshstring",
  "action": "none"
}
EOF
