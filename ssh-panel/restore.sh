#!/bin/bash
# My Telegram : https://t.me/Akbar218
# ==========================================
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
echo "This Feature Can Only Be Used According To Vps Data With This Autoscript"
echo "Please input link to your vps data backup file."
echo "You can check it on your email if you run backup data vps before."

echo -ne "Enter path file: "; read path
#read -rp "Path File: " -e url
#wget -O backup.zip "$url"
unzip $path

sleep 1
echo Start Restore
cd /root/backup
cp /root/backup/passwd /etc/
cp /root/backup/group /etc/
cp /root/backup/shadow /etc/
cp /root/backup/gshadow /etc/

echo Restore Done
echo -e "\nPress Enter key to return to main menu"; read
menu
