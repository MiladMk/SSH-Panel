#!/bin/bash

# Ensure clean string operations
export LANG="C.UTF-8"

clear

echo -e "\e[34m===================================================================================\e[0m"
echo -e "\e[1;32m                          SERVER ONLINE USERS DASHBOARD\e[0m"
echo -e "\e[34m===================================================================================\e[0m"

# Printed Table Header
printf "\e[1;33m%-20s %-12s %-8s %-15s %-18s\e[0m\n" "USERNAME" "SERVICE" "PORT" "PID" "IP ADDRESS"
echo -e "\e[34m-----------------------------------------------------------------------------------\--\e[0m"

TMP_FILE=$(mktemp)

# 1. Monitor OpenSSH Users
ps -eo user,pid,cmd | grep -E "sshd:" | grep -v -E "grep|root|sshd|privsep" | while read -r line; do
    USER=$(echo "$line" | awk '{print $1}')
    PID=$(echo "$line" | awk '{print $2}')
    CMD=$(echo "$line" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}')

    if [[ "$USER" == "root" || -z "$USER" ]]; then
        USER=$(echo "$CMD" | grep -oE 'sshd:[[:space:]]*[^[:space:]]+' | awk '{print $2}' | cut -d'@' -f1)
    fi

    if [[ ! -z "$USER" && "$USER" != "root" && "$USER" != "sshd" && "$USER" != "unknown" && "$USER" != *"/usr/sbin"* ]]; then
        IP=$(ss -tnp 2>/dev/null | grep -E "pid=$PID," | awk '{print $5}' | cut -d':' -f1 | head -n 1)
        if [[ -z "$IP" ]]; then IP="Unknown"; fi
        
        # ---------------------------------------------------------
        # تنظیم پورت پیش‌فرض OpenSSH سرور شما (اگر ۲۲ نیست تغییرش بده)
        SSH_PORT="22" 
        # ---------------------------------------------------------
        
        echo "$USER OpenSSH $SSH_PORT $PID $IP" >> "$TMP_FILE"
    fi
done

# Supplementary Check for OpenSSH
pgrep -f "sshd:" | while read -r PID; do
    if ! grep -q "$PID" "$TMP_FILE" 2>/dev/null; then
        LOG_LINE=$(journalctl _PID=$PID --since "2 hours ago" 2>/dev/null | grep -i "Accepted" | head -n 1)
        USER=$(echo "$LOG_LINE" | awk '{for(i=1;i<=NF;i++) if($i=="for") print $(i+1)}')
        IP=$(echo "$LOG_LINE" | awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}')
        
        if [[ ! -z "$USER" && "$USER" != "root" ]]; then
            if [[ -z "$IP" ]]; then IP="Unknown"; fi
            echo "$USER OpenSSH 22 $PID $IP" >> "$TMP_FILE"
        fi
    fi
done

# 2. Monitor Dropbear Users
ps -ef | grep "dropbear" | grep -E " -2 | -EF " | grep -v "grep" | while read -r line; do
    PID=$(echo "$line" | awk '{print $2}')
    
    LOG_LINE=$(journalctl _PID=$PID --since "3 hours ago" 2>/dev/null | grep -E -i "auth succeeded|Password auth succeeded" | head -n 1)
    
    USER=$(echo "$LOG_LINE" | grep -oE "auth succeeded for '[^']+'" | cut -d"'" -f2)
    if [[ -z "$USER" ]]; then
        USER=$(echo "$LOG_LINE" | awk '{for(i=1;i<=NF;i++) if($i=="for") print $(i+1)}' | tr -d "'\"")
    fi
    
    IP=$(ss -tnp 2>/dev/null | grep -E "pid=$PID," | awk '{print $5}' | cut -d':' -f1 | head -n 1)
    if [[ -z "$IP" || "$IP" == "127.0.0.1" ]]; then
        LOG_IP=$(echo "$LOG_LINE" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)
        if [[ ! -z "$LOG_IP" ]]; then IP=$LOG_IP; fi
    fi
    
    if [[ ! -z "$USER" && "$USER" != "root" ]]; then
        if [[ -z "$IP" ]]; then IP="Unknown"; fi
        
        # ---------------------------------------------------------
        # تنظیم پورت پیش‌فرض Dropbear سرور شما (اگر ۸۰۸۱ نیست تغییرش بده)
        DROPBEAR_PORT="8081"
        # ---------------------------------------------------------
        
        echo "$USER Dropbear $DROPBEAR_PORT $PID $IP" >> "$TMP_FILE"
    fi
done

# Render Sorted Output Table
if [ -s "$TMP_FILE" ]; then
    sort "$TMP_FILE" | uniq | while read -r UNAME UTILITY UPORT UPID UIP; do
        printf "\e[1;36m%-20s\e[0m %-12s %-8s %-15s %-18s\n" "$UNAME" "[$UTILITY]" "$UPORT" "$UPID" "$UIP"
    done
    
    echo -e "\e[34m-----------------------------------------------------------------------------------\e[0m"
    TOTAL_USERS=$(sort "$TMP_FILE" | uniq | wc -l)
    echo -e "\e[1;32mTotal Active Connections: $TOTAL_USERS\e[0m"
else
    echo -e "\e[1;31m[!] No active VPN tunnel accounts found online.\e[0m"
fi

rm -f "$TMP_FILE"
echo -e "\e[34m===================================================================================\e[0m"

menu
