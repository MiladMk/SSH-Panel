#!/bin/bash

clear

echo " "
echo " "
echo "=====================================================";
echo " "
echo " "

# ----------------=[ Dropbear User Login ]=----------------
echo "-----=[ Dropbear User Login ]=-----"
echo "PID   |   Username   |   IP Address"
echo "-------------------------------------"

# پیدا کردن تمام PIDهای پروسه dropbear
all_dropbear_pids=$(ps -C dropbear -o pid=)

for PID in $all_dropbear_pids; do
    # پیدا کردن PID والد. پروسه اصلی سیستم والدش شماره 1 (systemd) است.
    # پروسه‌های کاربران آنلاین، والدشان پروسه اصلی dropbear است (بزرگتر از 1).
    PPID_NUM=$(ps -o ppid= -p $PID | tr -d ' ')
    
    if [ ! -z "$PPID_NUM" ] && [ "$PPID_NUM" -gt 1 ]; then
        # استخراج لاگ اتصال از journalctl برای این PID خاص
        LOG_LINE=$(journalctl _PID=$PID --no-pager 2>/dev/null | grep -i "Password auth succeeded" | tail -n 1)
        
        if [ ! -z "$LOG_LINE" ]; then
            USER=$(echo "$LOG_LINE" | awk -F"for '" '{print $2}' | cut -d"'" -f1)
            IP=$(echo "$LOG_LINE" | awk -F"from " '{print $2}' | cut -d":" -f1)
            
            if [ ! -z "$USER" ] && [ "$USER" != "root" ]; then
                echo "$PID  -  $USER  -  $IP"
            fi
        fi
    fi
done

echo " "
# ----------------=[ OpenSSH User Login ]=----------------
echo "-----=[ OpenSSH User Login ]=-----"
echo "PID   |   Username   |   IP Address"
echo "-------------------------------------"

# پیدا کردن پروسه‌های فرزند SSH (کاربران آنلاین)
ssh_pids=$(ps aux | grep "sshd" | grep -v -E "grep|sshd -D" | awk '{print $2}')

for PID in $ssh_pids; do
    USER=$(ps -o user= -p $PID)
    
    if [ ! -z "$USER" ] && [ "$USER" != "root" ] && [ "$USER" != "sshd" ] && [ "$USER" != "reboot" ]; then
        # پیدا کردن IP با دستور ss (بدون سوئیچ‌های ناسازگار)
        IP=$(ss -tnpi 2>/dev/null | grep "pid=$PID," | awk '{print $5}' | cut -d: -f1 | sed -e 's/\[//g' -e 's/\]//g' | head -n 1)
        if [ -z "$IP" ]; then IP="Unknown"; fi
        echo "$PID  -  $USER  -  $IP"
    fi
done

echo " "
# ----------------=[ OpenVPN User Login ]=----------------
if [ -f "/etc/openvpn/openvpn-status.log" ]; then
    echo "-----=[ OpenVPN User Login ]=-----"
    echo "Username   |   IP Address   |   Connected Since"
    echo "-------------------------------------"
    
    sed -n '/Common Name,Real Address/,/ROUTING TABLE/p' /etc/openvpn/openvpn-status.log | grep -v -E "Common Name,Real Address|ROUTING TABLE" | while read -r line
    do
        if [ ! -z "$line" ]; then
            USER=$(echo "$line" | cut -d',' -f1)
            IP=$(echo "$line" | cut -d',' -f2 | cut -d':' -f1)
            SINCE=$(echo "$line" | cut -d',' -f5)
            echo "$USER  -  $IP  -  $SINCE"
        fi
    done
fi

echo " "
echo " "
echo "=====================================================";
echo " ";
echo " ";

echo -e "\nPress Enter key to return to main menu"; read
menu
