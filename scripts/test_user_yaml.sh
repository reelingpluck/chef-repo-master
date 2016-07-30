cat << EOF > data/$1.yaml
  $1:
    passwordclear: ""
    passwordmd5: "$2"
    private_key: "$3"
EOF
