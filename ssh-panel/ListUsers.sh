#!/bin/bash
# ==========================================
# Color
RED="\e[31m"
NC='\033[0m'
GREEN="\e[32m"
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
clear
echo "--------------------------------------------------------------------"
echo "USERNAME          EXP DATE          STATUS            Days to left  "
echo "--------------------------------------------------------------------"
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ "$exp" = "never" ]]; then
  expires="Never"
  else
  expires=$(date +%s -d "$exp")
  todaystime=`date +%s`
  countday=$(((expires-todaystime)/86400))
fi
if [[ "$AKUN" != "udpgw" ]]; then
  if [[ $ID -ge 1000 ]]; then
    if [[ "$status" = "L" ]]; then
      printf "%-17s %2s %-17s %01d \n" "$AKUN" "$exp     " "LOCKED        " "$countday"
    else
      printf "%-17s %2s %-17s %01d \n" "$AKUN" "$exp     " "UNLOCKED      " "$countday"
    fi
  fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo "---------------------------------------------------"
echo "Account number: $(($JUMLAH-1)) user"
echo "---------------------------------------------------"
echo -e "\nPress Enter key to return to main menu"; read
menu
