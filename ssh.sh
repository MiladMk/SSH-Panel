#!/bin/bash

#Font Colors

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"

clear

#public ip

pub_ip=$(wget -qO- https://ipecho.net/plain ; echo)

#root check

if ! [ $(id -u) = 0 ]; then
   echo -e "${RED}Plese run the script with root privilages!${ENDCOLOR}"
   exit 1
fi

spinner()
{
    #Loading spinner
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
pre_req()
{
        #installing pre-requirements and adding port rules to ubuntu firewall
		
	apt update -y && apt upgrade -y

        apt-get install -y dropbear && apt-get install -y stunnel4 && apt-get install -y squid && apt-get install -y cmake && apt-get install -y python3 && apt-get install -y screenfetch && apt-get install -y openssl && apt-get install -y zip && apt-get install -y git
        ufw allow 443/tcp
	ufw allow 444/tcp
        ufw allow 22/tcp
        ufw allow 80/tcp
        ufw allow 110/tcp
        ufw allow 8080/tcp
        ufw allow 7300/tcp
        ufw allow 7300/udp
}
mid_conf()
{

#configuring openssh

sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#Banner none/Banner \/etc\/banner/' /etc/ssh/sshd_config

#configuring dropbear

mv /etc/default/dropbear /etc/default/dropbear.backup
cat << EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_PORT=80
DROPBEAR_EXTRA_ARGS="-p 110"
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
EOF

#Adding the banner

cat << EOF > /etc/banner
<br>
Wellcome
EOF

#Configuring stunnel

mkdir /etc/stunnel
cat << EOF > /etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
client = no
sslVersion = all
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 110

[openssh]
accept = 444
connect = 22
EOF

#Genarating a self signed certificate for stunnel

openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
    -out stunnel.pem  -keyout stunnel.pem

cp stunnel.pem /etc/stunnel/stunnel.pem
chmod 644 /etc/stunnel/stunnel.pem

#Enable overide stunnel default

cp /etc/default/stunnel4 /etc/default/stunnel4.backup
sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4

# Configuring squid

mv /etc/squid/squid.conf /etc/squid/squid.conf.backup
cat << EOF > /etc/squid/squid.conf
acl url1 dstdomain -i 127.0.0.1
acl url2 dstdomain -i localhost
acl url3 dstdomain -i $pub_ip
acl url4 dstdomain -i /SSHPANEL?
acl payload url_regex -i "/etc/squid/payload.txt"

http_access allow url1
http_access allow url2
http_access allow url3
http_access allow url4
http_access allow payload
http_access deny all

http_port 8080
visible_hostname SSHPANEL
via off
forwarded_for off
pipeline_prefetch off
EOF
cat << EOF > /etc/squid/payload.txt
.whatsapp.net/
.facebook.net/
.twitter.com/
.speedtest.net/
EOF
}
fun_udpgw()
{
#build and install badvpn-udpgw

git clone https://github.com/ambrop72/badvpn
cd badvpn
cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install

#creating badvpn systemd service unit

cat << EOF > /etc/systemd/system/udpgw.service
[Unit]
Description=UDP forwarding for badvpn-tun2socks
After=nss-lookup.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000
User=udpgw

[Install]
WantedBy=multi-user.target
EOF
}
fun_panel()
{
mkdir /etc/ssh-panel
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/Banner.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/ChangePorts.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/ChangeUser.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/DelUser.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/ListUsers.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/RemoveScript.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/UserManager.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/auto-kill.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/auto-kill-lock.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/auto-reboot.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/bbr.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/ceklim.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/speedtest-cli
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/user-delete-expired.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/user-extend.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/user-lock.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/user-unlock.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/usersOnline.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/tendang
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/tendangandlock
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/unlock-blocked-users.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/auto-unlock.sh

wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/reboot.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/rebootcmd.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/backup.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/clearlog.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/restore.sh
wget https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/menu

mv Banner.sh /etc/ssh-panel/Banner.sh
mv ChangePorts.sh /etc/ssh-panel/ChangePorts.sh
mv ChangeUser.sh /etc/ssh-panel/ChangeUser.sh
mv DelUser.sh /etc/ssh-panel/DelUser.sh
mv ListUsers.sh /etc/ssh-panel/ListUsers.sh
mv RemoveScript.sh /etc/ssh-panel/RemoveScript.sh
mv UserManager.sh /etc/ssh-panel/UserManager.sh
mv auto-kill.sh /etc/ssh-panel/auto-kill.sh
mv auto-kill-lock.sh /etc/ssh-panel/auto-kill-lock.sh
mv auto-reboot.sh /etc/ssh-panel/auto-reboot.sh
mv bbr.sh /etc/ssh-panel/bbr.sh
mv ceklim.sh /etc/ssh-panel/ceklim.sh
mv speedtest-cli /etc/ssh-panel/speedtest-cli
mv user-delete-expired.sh /etc/ssh-panel/user-delete-expired.sh
mv user-extend.sh /etc/ssh-panel/user-extend.sh
mv user-lock.sh /etc/ssh-panel/user-lock.sh
mv user-unlock.sh /etc/ssh-panel/user-unlock.sh
mv usersOnline.sh /etc/ssh-panel/usersOnline.sh
mv tendang /usr/bin/tendang
mv tendangandlock /usr/bin/tendangandlock
mv unlock-blocked-users.sh /usr/bin/unlock-blocked-users.sh
mv auto-unlock.sh /etc/ssh-panel/auto-unlock.sh

mv reboot.sh /etc/ssh-panel/reboot.sh
cp /etc/ssh-panel/reboot.sh /etc/cron.d/reboot.sh
mv rebootcmd.sh /etc/ssh-panel/rebootcmd.sh
mv backup.sh /etc/ssh-panel/backup.sh
mv clearlog.sh /etc/ssh-panel/clearlog.sh
mv restore.sh /etc/ssh-panel/restore.sh
mv menu /usr/local/bin/menu

chmod +x /etc/ssh-panel/Banner.sh
chmod +x /etc/ssh-panel/ChangePorts.sh
chmod +x /etc/ssh-panel/ChangeUser.sh
chmod +x /etc/ssh-panel/DelUser.sh
chmod +x /etc/ssh-panel/ListUsers.sh
chmod +x /etc/ssh-panel/RemoveScript.sh
chmod +x /etc/ssh-panel/UserManager.sh
chmod +x /etc/ssh-panel/auto-kill.sh
chmod +x /etc/ssh-panel/auto-kill-lock.sh
chmod +x /etc/ssh-panel/auto-reboot.sh
chmod +x /etc/ssh-panel/bbr.sh
chmod +x /etc/ssh-panel/ceklim.sh
chmod +x /etc/ssh-panel/speedtest-cli
chmod +x /etc/ssh-panel/user-delete-expired.sh
chmod +x /etc/ssh-panel/user-extend.sh
chmod +x /etc/ssh-panel/user-lock.sh
chmod +x /etc/ssh-panel/user-unlock.sh
chmod +x /etc/ssh-panel/usersOnline.sh
chmod +x /etc/ssh-panel/auto-unlock.sh

chmod +x /usr/bin/tendang
chmod +x /usr/bin/tendangandlock
chmod +x /usr/bin/unlock-blocked-users.sh
chmod +x /etc/ssh-panel/reboot.sh
chmod +x /etc/cron.d/reboot.sh
chmod +x /etc/ssh-panel/rebootcmd.sh
chmod +x /etc/ssh-panel/backup.sh
chmod +x /etc/ssh-panel/clearlog.sh
chmod +x /etc/ssh-panel/restore.sh
chmod +x /usr/local/bin/menu

}
fun_service_start()
{
#enabling and starting all services

useradd -m udpgw

systemctl restart sshd
systemctl enable dropbear
systemctl restart dropbear
systemctl enable stunnel4
systemctl restart stunnel4
systemctl enable squid
systemctl restart squid
systemctl enable udpgw
systemctl restart udpgw
}
echo -ne "${GREEN}Installing required packages ............."
pre_req >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo -ne "\n${BLUE}Configuring Stunnel, Openssh, Dropbear and Squid ............."
mid_conf >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo -ne "\n${YELLOW}Compiling and installing Badvpn UDP Gateway ............."
fun_udpgw >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo -ne "\n${CYAN}Installing Panel ............."
fun_panel >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo -ne "\n${RED}Starting All the services ............."
fun_service_start >/dev/null 2>&1 &
spinner
echo -ne "\tdone"
echo -e "${ENDCOLOR}"

#configure user shell to /bin/false
echo /bin/false >> /etc/shells
clear

#Adding the default user
echo -ne "${GREEN}Enter the default username : "; read username
while true; do
    read -p "Do you want to genarate a random password ? (Y/N) " yn
    case $yn in
        [Yy]* ) password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-9};echo;); break;;
        [Nn]* ) echo -ne "Enter password (please use a strong password) : "; read password; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo -ne "Enter No. of Days till expiration : ";read nod
exd=$(date +%F  -d "$nod days")
useradd -e $exd -M -N -s /bin/false $username && echo "$username:$password" | chpasswd &&
clear &&
echo -e "${GREEN}Default User Details" &&
echo -e "${RED}--------------------" &&
echo -e "${GREEN}\nUsername :${YELLOW} $username" &&
echo -e "${GREEN}\nPassword :${YELLOW} $password" &&
echo -e "${GREEN}\nExpire Date :${YELLOW} $exd ${ENDCOLOR}" ||
echo -e "${RED}\nFailed to add default user $username please try again.${ENDCOLOR}"

#exit script
echo -e "\n${CYAN}Script installed. You can access the panel using 'menu' command. ${ENDCOLOR}\n"
echo -e "\nPress Enter key to exit"; read
