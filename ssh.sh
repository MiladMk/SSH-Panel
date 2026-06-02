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
   echo -e "${RED}Please run the script with root privileges!${ENDCOLOR}"
   exit 1
fi

spinner()
{
    #Loading spinner
    local pid=$!
    local delay=0.15
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
    # بروزرسانی مخازن و نصب پکیج‌های مورد نیاز (stunnel4 به stunnel تغییر یافته)
    apt-get update -y
    apt-get install -y dropbear stunnel4 squid cmake python3 screenfetch openssl zip git mutt ufw net-tools build-essential
    
    # تنظیمات فایروال
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
    # پیکربندی OpenSSH
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#Banner none/Banner \/etc\/banner/' /etc/ssh/sshd_config

    # پیکربندی Dropbear
    if [ -d "/etc/default" ]; then
        mv /etc/default/dropbear /etc/default/dropbear.backup 2>/dev/null
        cat << EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_PORT=80
DROPBEAR_EXTRA_ARGS="-p 110 -W 65536"
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
    fi

    # ایجاد بنر خوش‌آمدگویی
    cat << EOF > /etc/banner
<br>
Welcome to SSH Panel Pro
EOF

    # پیکربندی Stunnel
    mkdir -p /etc/stunnel
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

    # تولید سرتیفیکیت خودامضا برای Stunnel
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
        -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem
    chmod 600 /etc/stunnel/stunnel.pem

    # فعال‌سازی خودکار Stunnel در اوبونتو
    if [ -f "/etc/default/stunnel4" ]; then
        sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
    fi

    # پیکربندی Squid Proxy
    mv /etc/squid/squid.conf /etc/squid/squid.conf.backup 2>/dev/null
    cat << EOF > /etc/squid/squid.conf
acl url1 dstdomain -i 127.0.0.1
acl url2 dstdomain -i localhost
acl url3 dstdomain -i $pub_ip
acl payload url_regex -i "/etc/squid/payload.txt"

http_access allow url1
http_access allow url2
http_access allow url3
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
    # ایجاد کاربر سیستمی مخصوص udpgw قبل از کانفیگ سرویس برای جلوگیری از باگ استارت
    id -u udpgw &>/dev/null || useradd --system --shell /bin/false udpgw

    # دانلود، کامپایل و نصب badvpn-udpgw
    cd /root
    rm -rf badvpn
    git clone https://github.com/ambrop72/badvpn.git
    cd badvpn
    mkdir build && cd build
    cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
    make install
    cd /root
    rm -rf badvpn

    # ایجاد فایل سرویس systemd برای udpgw
    cat << EOF > /etc/systemd/system/udpgw.service
[Unit]
Description=UDP forwarding for badvpn-tun2socks
After=network.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000
User=udpgw
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

fun_panel()
{
    mkdir -p /etc/ssh-panel
    mkdir -p /etc/DNSUpdater
    
    # دریافت اسکریپت‌ها از گیت‌هاب شما
    cd /root
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/Banner.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/ChangePorts.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/ChangeUser.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/DelUser.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/ListUsers.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/RemoveScript.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/UserManager.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/auto-kill.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/auto-kill-lock.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/auto-reboot.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/bbr.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/ceklim.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/speedtest-cli
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/user-delete-expired.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/user-extend.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/user-lock.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/user-unlock.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/usersOnline.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/tendang
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/tendangandlock
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/unlock-blocked-users.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/auto-unlock.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/show-expire-users.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/lock-expire-users.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/auto-backup-send-email.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/tendangandautomail
    wget -q https://github.com/MiladMk/SSH-Panel/raw/main/ssh-panel/add-udp-port.sh

    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/reboot.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/rebootcmd.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/backup.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/clearlog.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/ssh-panel/restore.sh
    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/menu

    wget -q https://raw.githubusercontent.com/MiladMk/SSH-Panel/main/DNSUpdater/update_dns_ip.sh
    wget -q https://github.com/MiladMk/SSH-Panel/raw/main/DNSUpdater/index_current_server.txt
    wget -q https://github.com/MiladMk/SSH-Panel/raw/main/DNSUpdater/ip.txt
    wget -q https://github.com/MiladMk/SSH-Panel/raw/main/DNSUpdater/ip_log.txt

    # انتقال فایل‌ها به مسیرهای مربوطه
    mv Banner.sh /etc/ssh-panel/Banner.sh 2>/dev/null
    mv ChangePorts.sh /etc/ssh-panel/ChangePorts.sh 2>/dev/null
    mv ChangeUser.sh /etc/ssh-panel/ChangeUser.sh 2>/dev/null
    mv DelUser.sh /etc/ssh-panel/DelUser.sh 2>/dev/null
    mv ListUsers.sh /etc/ssh-panel/ListUsers.sh 2>/dev/null
    mv RemoveScript.sh /etc/ssh-panel/RemoveScript.sh 2>/dev/null
    mv UserManager.sh /etc/ssh-panel/UserManager.sh 2>/dev/null
    mv auto-kill.sh /etc/ssh-panel/auto-kill.sh 2>/dev/null
    mv auto-kill-lock.sh /etc/ssh-panel/auto-kill-lock.sh 2>/dev/null
    mv auto-reboot.sh /etc/ssh-panel/auto-reboot.sh 2>/dev/null
    mv bbr.sh /etc/ssh-panel/bbr.sh 2>/dev/null
    mv ceklim.sh /etc/ssh-panel/ceklim.sh 2>/dev/null
    mv speedtest-cli /etc/ssh-panel/speedtest-cli 2>/dev/null
    mv user-delete-expired.sh /etc/ssh-panel/user-delete-expired.sh 2>/dev/null
    mv user-extend.sh /etc/ssh-panel/user-extend.sh 2>/dev/null
    mv user-lock.sh /etc/ssh-panel/user-lock.sh 2>/dev/null
    mv user-unlock.sh /etc/ssh-panel/user-unlock.sh 2>/dev/null
    mv usersOnline.sh /etc/ssh-panel/usersOnline.sh 2>/dev/null
    mv tendang /usr/bin/tendang 2>/dev/null
    mv tendangandlock /usr/bin/tendangandlock 2>/dev/null
    mv unlock-blocked-users.sh /usr/bin/unlock-blocked-users.sh 2>/dev/null
    mv auto-unlock.sh /etc/ssh-panel/auto-unlock.sh 2>/dev/null
    mv show-expire-users.sh /etc/ssh-panel/show-expire-users.sh 2>/dev/null
    mv lock-expire-users.sh /etc/ssh-panel/lock-expire-users.sh 2>/dev/null
    mv auto-backup-send-email.sh /etc/ssh-panel/auto-backup-send-email.sh 2>/dev/null
    mv tendangandautomail /usr/bin/tendangandautomail 2>/dev/null
    mv add-udp-port.sh /etc/ssh-panel/add-udp-port.sh 2>/dev/null

    mv reboot.sh /etc/ssh-panel/reboot.sh 2>/dev/null
    cp /etc/ssh-panel/reboot.sh /etc/cron.d/reboot.sh 2>/dev/null
    mv rebootcmd.sh /etc/ssh-panel/rebootcmd.sh 2>/dev/null
    mv backup.sh /etc/ssh-panel/backup.sh 2>/dev/null
    mv clearlog.sh /etc/ssh-panel/clearlog.sh 2>/dev/null
    mv restore.sh /etc/ssh-panel/restore.sh 2>/dev/null
    mv menu /usr/local/bin/menu 2>/dev/null

    mv update_dns_ip.sh /etc/DNSUpdater/update_dns_ip.sh 2>/dev/null
    mv index_current_server.txt /etc/DNSUpdater/index_current_server.txt 2>/dev/null
    mv ip.txt /etc/DNSUpdater/ip.txt 2>/dev/null
    mv ip_log.txt /etc/DNSUpdater/ip_log.txt 2>/dev/null

    # اختصاص دسترسی‌های لازم
    chmod 700 /etc/ssh-panel/*.sh 2>/dev/null
    chmod 700 /etc/ssh-panel/speedtest-cli 2>/dev/null
    chmod 700 /usr/bin/tendang* 2>/dev/null
    chmod 700 /usr/bin/unlock-blocked-users.sh 2>/dev/null
    chmod 700 /usr/local/bin/menu 2>/dev/null
    chmod 700 /etc/DNSUpdater/*.sh 2>/dev/null
}

fun_service_start()
{
    # ریست و لود مجدد سرویس‌ها با استفاده از معماری بومی systemd اوبونتو ۲۴
    systemctl daemon-reload
    
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    
    systemctl enable dropbear
    systemctl restart dropbear
    
    systemctl enable stunnel4 2>/dev/null || systemctl enable stunnel
    systemctl restart stunnel4 2>/dev/null || systemctl restart stunnel
    
    systemctl enable squid
    systemctl restart squid
    
    systemctl enable udpgw
    systemctl restart udpgw
}

# شروع مراحل نصب
echo -ne "${GREEN}Installing required packages ............."
pre_req >/dev/null 2>&1 &
spinner
echo -ne "\tdone"

echo -ne "\n${BLUE}Configuring Stunnel, OpenSSH, Dropbear and Squid ............."
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

# تنظیم شل پیش‌فرض برای امنیت کاربران غیرمجاز
grep -qxF '/bin/false' /etc/shells || echo /bin/false >> /etc/shells
clear

# بخش اضافه کردن کاربر پیش‌فرض
echo -ne "${GREEN}Enter the default username : "; read username
while true; do
    read -p "Do you want to generate a random password ? (Y/N) " yn
    case $yn in
        [Yy]* ) password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c 9; echo;); break;;
        [Nn]* ) echo -ne "Enter password (please use a strong password) : "; read password; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -ne "Enter No. of Days till expiration : "; read nod
exd=$(date +%F -d "$nod days")

useradd -e $exd -M -N -s /bin/false $username && echo "$username:$password" | chpasswd && \
clear && \
echo -e "${GREEN}Default User Details" && \
echo -e "${RED}--------------------" && \
echo -e "${GREEN}\nUsername :${YELLOW} $username" && \
echo -e "${GREEN}\nPassword :${YELLOW} $password" && \
echo -e "${GREEN}\nExpire Date :${YELLOW} $exd ${ENDCOLOR}" || \
echo -e "${RED}\nFailed to add default user $username please try again.${ENDCOLOR}"

echo -e "\n${CYAN}Script installed successfully. You can access the panel using 'menu' command. ${ENDCOLOR}\n"
echo -e "\nPress Enter key to exit"; read
