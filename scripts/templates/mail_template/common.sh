#!/bin/bash
#
# Author:: Eugene Narciso <eugene.narciso@itaas.dimensiondata.com>
# Description: Common functions used across multiple shell scripts
###

# This verify_email section will map the users name with mail id's to avoid the duplicate entries in future.
verify_email () {
  suffix=$( echo "$email" | cut -d '@' -f2 )
  if [[ "$suffix" == "itaas.com" || "$suffix" == "dimensiondata.com" || "$suffix" == "itaas.dimensiondata.com" ]]; then
    echo "You have provided the offical mail id"
  else
    echo -e "\e[1;31myour maild is not in the correct format, Please provide your offical mail id\e[0m"
    exit 1
  fi
}

get_user () {
  grep -w $email < data/emails.sh | cut -d ':' -f1
}

highest_uid () {
  if [ -d data_bags/users ]; then
    grep "uid" data_bags/users/*.json |awk '{print $3}' |sort -n |awk  END{print} |cut -d, -f1 |tr -d '"'
  else
    echo "Missing data_bags/users directory"
    exit 1
  fi
}

group_change () {
  #i=`echo $group | cut -d',' -f1-5 --output-delimiter=$'\n' | wc -l`
  if [ -f scripts/group_add.sh ]; then
    bash scripts/group_add.sh  > scripts/test_user_add_bak.sh
  else
    echo "File group_add.sh is missing"
    exit 1
  fi
}