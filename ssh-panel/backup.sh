#!/bin/bash
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
IP=$(wget -qO- ipinfo.io/ip);
date=$(date +"%Y-%m-%d")
clear
echo "Create Backup"
cd /root
rm -rf /root/backup
mkdir /root/backup
cp /etc/passwd backup/
cp /etc/group backup/
cp /etc/shadow backup/
cp /etc/gshadow backup/
cd /root
zip -r backup.zip backup > /dev/null 2>&1

echo -e "
Detail Backup 
==================================
IP VPS        : $IP
Directory     : /root/backup.zip
Date          : $date
==================================
"
echo -e "\nPress Enter key to return to main menu"; read
menu
