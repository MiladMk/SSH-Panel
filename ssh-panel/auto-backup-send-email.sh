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
cek=$(grep -c -E "^# AutoBackupSendEmail" /etc/cron.d/tendangandautomail)
if [[ "$cek" = "1" ]]; then
sts="${Info}"
else
sts="${Error}"
fi
clear
echo -e ""
echo -e "=================================="
echo -e "       Status AutoBackupSendEmail $sts       "
echo -e "=================================="
echo -e "1. AutoBackupSendEmail At 23:30 o'clock"
echo -e "2. Turn Off AutoBackupSendEmail"
echo -e "3. Exit"
echo -e "=================================="                                                                                                          
echo -e ""
read -p "Select From Options [1-2 or x] :  " AutoBackupSendEmail
echo -e ""
case $AutoBackupSendEmail in
                1)
                echo -e ""
                read -p "Email Address: " email
                clear
                echo > /etc/cron.d/tendangandautomail
                echo "# AutoBackupSendEmail" >>/etc/cron.d/tendangandautomail
                echo "30 23 * * *  root /usr/bin/tendangandautomail $email" >>/etc/cron.d/tendangandautomail
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoBackupSendEmail   : At 23:30"   
                echo -e "      Email Address         : $email        "   
                echo -e ""
                echo -e "======================================"                                                                                                                                 
                exit                                                                  
                ;;
                2)
                clear
                echo > /etc/cron.d/tendangandautomail
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoBackupSendEmail MultiLogin Turned Off  "
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
