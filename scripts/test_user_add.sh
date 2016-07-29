cat << EOF > $WORKSPACE/data_bags/users/$1.json
{
  "id": "$1",
  "uid": "$3",
  "groups": [
    "$4",
    "users"
  ],
  "shell": "/bin/bash",
  "home_dir": "/home/$1",
  "comment": "$2",
  "ssh_keys": "$5",
  "action": "none"
}
EOF
