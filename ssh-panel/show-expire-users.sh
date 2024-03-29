#!/bin/bash

clear

hariini=`date +%d-%m-%Y`
echo " "
echo " "
echo "-------------------------------------------"
cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
totalaccounts=`cat /tmp/expirelist.txt | wc -l`
for((i=1; i<=$totalaccounts; i++ ))
       do
       tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
       username=`echo $tuserval | cut -f1 -d:`
       userexp=`echo $tuserval | cut -f2 -d:`
       userexpireinseconds=$(( $userexp * 86400 ))
       tglexp=`date -d @$userexpireinseconds`             
       tgl=`echo $tglexp |awk -F" " '{print $3}'`
       while [ ${#tgl} -lt 2 ]
       do
           tgl="0"$tgl
       done
       while [ ${#username} -lt 15 ]
       do
           username=$username" " 
       done
       bulantahun=`echo $tglexp |awk -F" " '{print $2,$6}'`
       echo "echo "VPS-Murah.net- User : $username Date Expired On : $tgl $bulantahun"" >> /usr/local/bin/alluser
       todaystime=`date +%s`
       twoday=$(($todaystime+172800))
       if [ $userexpireinseconds -ge $twoday ] ;
           then
			:
       else 
         status="$(passwd -S $username | awk '{print $2}' )"
           if [[ "$status" = "L" ]]; then
             echo "Username : $username already expired On Date: $tgl $bulantahun (LOCKED)"
           else
             echo "Username : $username already expired On Date: $tgl $bulantahun (UNLOCKED)"
           fi
       fi
done

echo -e "\nPress Enter key to return to main menu"; read
menu
