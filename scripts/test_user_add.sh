cat << EOF > data_bags/users/$1.json
{
  "id": "$1",
  "uid": "$3",
  "groups": [
    "users"
  ],
  "shell": "/bin/bash",
  "home_dir": "/home/$1",
  "comment": "$2",
  "ssh_keys": "$9",
  "action": "CREATE"
}
EOF
