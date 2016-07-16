cat << EOF > $WORKSPACE/data_bags/private_keys/$1.json
{
  "id": "$1",
    "passwordclear": "",
    "passwordmd5" "$2",
    "private_key": "$3"
}
EOF
