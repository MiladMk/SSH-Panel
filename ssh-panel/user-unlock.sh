#!/bin/bash


clear
echo " "
echo " "
echo " "
read -p "Input USERNAME to unlock: " username
egrep "^$username" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
# proses mengganti passwordnya
passwd -u $username
clear
  echo " "
  echo " "
  echo " "
  echo "-------------------------------------------"
  echo -e "Username ${blue}$username${NC} successfully ${green}UNLOCKED${NC}."
  echo -e "Access for Username ${blue}$username${NC} has been restored"
  echo "-------------------------------------------"
else
echo " "
echo -e "Username ${red}$username${NC} not found in your server."
echo " "    
	exit 1
fi
echo -e "\nPress Enter key to return to main menu"; read
menu
