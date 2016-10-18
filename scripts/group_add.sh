i=`echo $group | cut -d',' -f1-5 --output-delimiter=$'\n' | wc -l`
echo $group | cut -d',' -f1-5 --output-delimiter=$'\n' >> $username.sh
a=`expr 4 + "$i"`
case $i in
   1) sed  -e  '/group/a \ "$4",' -e '/"ssh_keys": "$9",/c\  "ssh_keys": "$'`echo $a`'",' scripts/test_user_add.sh
   ;;
   2) sed  -e  '/group/a \ "$4",\n"$5",' -e '/"ssh_keys": "$9",/c\  "ssh_keys": "$'`echo $a`'",' scripts/test_user_add.sh
   ;;
   3) sed  -e  '/group/a \ "$4",\n"$5",\n"$6",' -e '/"ssh_keys": "$9",/c\  "ssh_keys": "$'`echo $a`'",' scripts/test_user_add.sh
   ;;
   4) sed   -e '/group/a \ "$4",\n"$5",\n"$6",\n "$7",' -e '/"ssh_keys": "$9",/c\  "ssh_keys": "$'`echo $a`'",' scripts/test_user_add.sh
   ;;
   5) sed  -e  '/group/a \ "$4",\n"$5",\n"$6",\n"$7",\n"$8",' -e '/"ssh_keys": "$9",/c\  "ssh_keys": "$'`echo $a`'",' scripts/test_user_add.sh
   ;;
esac
