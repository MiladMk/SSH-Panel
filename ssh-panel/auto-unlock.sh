#!/bin/bash
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
clear
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"
cek=$(grep -c -E "^# AutoUnlock" /etc/cron.d/unlock-blocked-users)
if [[ "$cek" = "1" ]]; then
sts="${Info}"
else
sts="${Error}"
fi
clear
echo -e ""
echo -e "=================================="
echo -e "       Status Auto Unlock Blocked Users $sts       "
echo -e "=================================="
echo -e "0. AutoUnlock After 1 Minutes"
echo -e "1. AutoUnlock After 5 Minutes"
echo -e "2. AutoUnlock After 10 Minutes"
echo -e "3. AutoUnlock After 15 Minutes"
echo -e "4. AutoUnlock After 30 Minutes"
echo -e "5. AutoUnlock After 60 Minutes"
echo -e "6. Turn Off AutoUnlock"
echo -e "7. Exit"
echo -e "=================================="                                                                                                          
echo -e ""
read -p "Select From Options [1-4 or x] :  " AutoUnlock
echo -e ""
case $AutoUnlock in
                0)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/unlock-blocked-users
                echo "# AutoUnlock" >>/etc/cron.d/unlock-blocked-users
                echo "*/1 * * * *  root /usr/bin/unlock-blocked-users.sh" >>/etc/cron.d/unlock-blocked-users
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoUnlock Every     : 1 Minutes"      
                echo -e ""
                echo -e "======================================"                                                                                                                                 
                exit                                                                  
                ;;
                1)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/unlock-blocked-users
                echo "# AutoUnlock" >>/etc/cron.d/unlock-blocked-users
                echo "*/5 * * * *  root /usr/bin/unlock-blocked-users.sh" >>/etc/cron.d/unlock-blocked-users
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoUnlock Every     : 5 Minutes"      
                echo -e ""
                echo -e "======================================"                                                                                                                                 
                exit                                                                  
                ;;
                2)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/unlock-blocked-users
                echo "# AutoUnlock" >>/etc/cron.d/unlock-blocked-users
                echo "*/10 * * * *  root /usr/bin/unlock-blocked-users.sh" >>/etc/cron.d/unlock-blocked-users
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoUnlock Every     : 10 Minutes"
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                3)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/unlock-blocked-users
                echo "# AutoUnlock" >>/etc/cron.d/unlock-blocked-users
                echo "*/15 * * * *  root /usr/bin/unlock-blocked-users.sh" >>/etc/cron.d/unlock-blocked-users
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoUnlock Every     : 15 Minutes"
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                4)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/unlock-blocked-users
                echo "# AutoUnlock" >>/etc/cron.d/unlock-blocked-users
                echo "*/30 * * * *  root /usr/bin/unlock-blocked-users.sh" >>/etc/cron.d/unlock-blocked-users
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoUnlock Every     : 30 Minutes"
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                5)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/unlock-blocked-users
                echo "# AutoUnlock" >>/etc/cron.d/unlock-blocked-users
                echo "*/60 * * * *  root /usr/bin/unlock-blocked-users.sh" >>/etc/cron.d/unlock-blocked-users
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoUnlock Every     : 60 Minutes"
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                6)
                clear
                echo > /etc/cron.d/unlock-blocked-users
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoUnlock MultiLogin Turned Off  "
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                x)
                clear
                exit
                ;;
        esac
echo -e "\nPress Enter key to return to main menu";read
menu
