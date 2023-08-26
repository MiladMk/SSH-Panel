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
cek=$(grep -c -E "^# Autokill" /etc/cron.d/tendangandlock)
if [[ "$cek" = "1" ]]; then
sts="${Info}"
else
sts="${Error}"
fi
clear
echo -e ""
echo -e "=================================="
echo -e "       Status Autokill $sts       "
echo -e "=================================="
echo -e "0. AutoKill After 1 Minutes"
echo -e "1. AutoKill After 5 Minutes"
echo -e "2. AutoKill After 10 Minutes"
echo -e "3. AutoKill After 15 Minutes"
echo -e "4. Turn Off AutoKill/MultiLogin"
echo -e "5. Exit"
echo -e "=================================="                                                                                                          
echo -e ""
read -p "Select From Options [1-4 or x] :  " AutoKill
read -p "Multilogin Maximum Number Of Allowed: " max
echo -e ""
case $AutoKill in
                0)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/tendangandlock
                echo "# Autokill" >>/etc/cron.d/tendangandlock
                echo "*/1 * * * *  root /usr/bin/tendangandlock $max" >>/etc/cron.d/tendangandlock
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      Allowed MultiLogin : $max"
                echo -e "      AutoKill Every     : 1 Minutes"      
                echo -e ""
                echo -e "======================================"                                                                                                                                 
                exit                                                                  
                ;;
                1)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/tendangandlock
                echo "# Autokill" >>/etc/cron.d/tendangandlock
                echo "*/5 * * * *  root /usr/bin/tendangandlock $max" >>/etc/cron.d/tendangandlock
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      Allowed MultiLogin : $max"
                echo -e "      AutoKill Every     : 5 Minutes"      
                echo -e ""
                echo -e "======================================"                                                                                                                                 
                exit                                                                  
                ;;
                2)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/tendangandlock
                echo "# Autokill" >>/etc/cron.d/tendangandlock
                echo "*/10 * * * *  root /usr/bin/tendangandlock $max" >>/etc/cron.d/tendangandlock
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      Allowed MultiLogin : $max"
                echo -e "      AutoKill Every     : 10 Minutes"
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                3)
                echo -e ""
                sleep 1
                clear
                echo > /etc/cron.d/tendangandlock
                echo "# Autokill" >>/etc/cron.d/tendangandlock
                echo "*/15 * * * *  root /usr/bin/tendangandlock $max" >>/etc/cron.d/tendangandlock
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      Allowed MultiLogin : $max"
                echo -e "      AutoKill Every     : 15 Minutes"
                echo -e ""
                echo -e "======================================"
                exit
                ;;
                4)
                clear
                echo > /etc/cron.d/tendangandlock
                echo -e ""
                echo -e "======================================"
                echo -e ""
                echo -e "      AutoKill MultiLogin Turned Off  "
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
