#!/bin/bash

IFS=$'\r\n' GLOBIGNORE='*' command eval  'users=($(cat /etc/DNSUpdater/ip.txt))'
index=$(< /etc/DNSUpdater/index_current_server.txt)
length=${#users[@]}
((index++))
if (( index >= length )); then
index=0
fi

myip=${users[$index]}

echo "$index" > /etc/DNSUpdater/index_current_server.txt

LOG_FILE="/etc/DNSUpdater/ip_log.txt"
DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")

ZONE_ID=zoneid
A_record=recordname
A_record_id=arecordid
CF_BEARER=apikey

IP=$myip

if [[ $IP =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]]; then

DATA_TO_UPDATE="{\"type\":\"A\",\"name\":\"$A_record\",\"content\":\"$IP\",\"ttl\":1,\"proxied\":false}"
curl -X PUT "https://api.cloudflare.com/client/v4/zones/"$ZONE_ID"/dns_records/"$A_record_id -H "Authorization: Bearer ${CF_BEARER}" -H "Content-Type:application/json" --data $DATA_TO_UPDATE

echo "Date Time: ${DATE_TIME} - Set IP: ${IP} Sub Domain: ${A_record}" >> "$LOG_FILE"
fi
