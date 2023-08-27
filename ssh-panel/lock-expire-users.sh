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
       if [ $userexpireinseconds -ge $todaystime ] ;
           then
			:
       else
       echo "echo "Username : $username already expired On Date: $tgl $bulantahun has been Locked on:: $hariini "" >> /usr/local/bin/Lockeduser
	   echo "Username $username expired on $tgl $bulantahun successfully locked from the system on $hariini"
       passwd -l $username
       fi
done

echo -e "\nPress Enter key to return to main menu"; read
menu
