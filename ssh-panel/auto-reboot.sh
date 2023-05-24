#!/bin/bash
clear

if [ ! -e /etc/ssh-panel/reboot.sh ]; then
echo '#!/bin/bash' > /etc/ssh-panel/reboot.sh 
echo 'tanggal=$(date +"%m-%d-%Y")' >> /etc/ssh-panel/reboot.sh
echo 'waktu=$(date +"%T")' >> /etc/ssh-panel/reboot.sh 
echo 'echo "Server successfully rebooted on the date of $tanggal hit $waktu." >> /root/log-reboot.txt' >> /etc/ssh-panel/reboot.sh
echo '/sbin/shutdown -r now' >> /etc/ssh-panel/reboot.sh
chmod +x /etc/ssh-panel/reboot.sh
chmod +x /etc/ssh-panel/rebootcmd.sh
fi

echo "-------------------------------------------"
echo "          System Auto Reboot Menu          "
echo "-------------------------------------------"
echo "1.  Set Auto-Reboot Every 1 Hour"
echo "2.  Set Auto-Reboot Every 6 Hours"
echo "3.  Set Auto-Reboot Every 12 Hours"
echo "4.  Set Auto-Reboot Once a Day"
echo "5.  Set Auto-Reboot Once a Week"
echo "6.  Set Auto-Reboot Once a Month"
echo "7.  Turn off Auto-Reboot"
echo "8.  View reboot log"
echo "9.  Remove reboot log"
echo "-------------------------------------------"
read -p "Select options from (1-9): " x

if test $x -eq 1; then
echo "10 * * * * root /etc/ssh-panel/reboot.sh" > /etc/cron.d/reboot.sh
echo "Auto-Reboot has been set every an hour."
elif test $x -eq 2; then
echo "10 */6 * * * root /etc/ssh-panel/reboot.sh" > /etc/cron.d/reboot.sh
echo "Auto-Reboot has been successfully set every 6 hours."
elif test $x -eq 3; then
echo "10 */12 * * * root /etc/ssh-panel/reboot.sh" > /etc/cron.d/reboot.sh
echo "Auto-Reboot has been successfully set every 12 hours."
elif test $x -eq 4; then
echo "10 4 * * * root /etc/ssh-panel/reboot.sh" > /etc/cron.d/reboot.sh
echo "Auto-Reboot has been successfully set once a day."
elif test $x -eq 5; then
echo "10 0 */7 * * root /etc/ssh-panel/reboot.sh" > /etc/cron.d/reboot.sh
echo "Auto-Reboot has been successfully set once a week."
elif test $x -eq 6; then
echo "10 0 1 * * root /etc/ssh-panel/reboot.sh" > /etc/cron.d/reboot.sh
echo "Auto-Reboot has been successfully set once a month."
elif test $x -eq 7; then
rm -f /etc/cron.d/reboot.sh
echo "Auto-Reboot successfully TURNED OFF."
elif test $x -eq 8; then
if [ ! -e /root/log-reboot.txt ]; then
	echo "No reboot activity found"
	else 
	echo 'LOG REBOOT'
	echo "-------"
	cat /root/log-reboot.txt
fi
elif test $x -eq 9; then
echo "" > /root/log-reboot.txt
echo "Auto Reboot Log successfully deleted!"
else
echo "Options Not Found In Menu"
exit
fi
echo -e "\nPress Enter key to return to main menu";read
menu
