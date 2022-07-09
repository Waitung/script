#!/bin/bash

url_repo="https://github.com/Waitung/script/raw/main"

run(){
    check_value "$@"
    echo_install
    input
    echo_domain_name
    confirm_install
}

check_value(){
    if [ -n "$1" ]; then
        confirm_value "$@"
    else
        input_value
    fi
}

input_value(){
    readme="
    ==========  ==========  ==========  ==========  ==========
    阿里云轻量 Debian 10.5 自用脚本
    ----------
    选择要安装的工具，选项以空格分开，例:1 2 3 4 5 6 7 8 9 
      1. Caddy (webserver,必装，脚本里都以此为基础)
      2. FileBrowser (网页文件浏览器)
      3. webdav (caddy插件)
      4. Aria2 (下载工具)
      5. AriaNG (aria2 web前端)
      6. Syncthing (文件同步工具)
      7. Typecho (博客工具)
      8. Dokcer
      9. Cloudreve (网盘工具)
      10. php
    ----------
    脚本用于新系统下安装，在输入完信息前不会安装任何东西， Ctrl+C 终止。
    ==========  ==========  ==========  ==========  =========="
    echo -e "${readme}"
    read -p "输入正确选项：" -a value
    confirm_value "${value[@]}"
}

confirm_value(){
    caddy=0
    filebrowser=0
    webdav=0
    aria2=0
    ariang=0
    syncthing=0
    typecho=0
    docker=0
    cloudreve=0
    php=0
    while [ -n "$1" ]; do
        case "$1" in 
            1 ) caddy=1;;
            2 ) filebrowser=1;;
            3 ) webdav=1;;
            4 ) aria2=1;;
            5 ) ariang=1;;
            6 ) syncthing=1;;
            7 ) typecho=1; check_php;;
            8 ) docker=1;;
            9 ) cloudreve=1;;
            10 ) php=1;;
            * ) echo -e "\n\033[31m$1 不是有效选项，重新选择\033[0m"; input_value; break;;
        esac
        shift
    done
}

echo_install(){
    echo -e "\n---------------\n接下来会安装："
    if [ ${caddy} -eq 1 ]; then echo "Caddy"; fi
    if [ ${filebrowser} -eq 1 ]; then echo "FileBrowser"; fi
    if [ ${webdav} -eq 1 ]; then echo "webdav"; fi
    if [ ${aria2} -eq 1 ]; then echo "Aria2"; fi
    if [ ${ariang} -eq 1 ]; then echo "AriaNG"; fi
    if [ ${syncthing} -eq 1 ]; then echo "Syncthing"; fi
    if [ ${typecho} -eq 1 ]; then echo "Typecho"; fi
    if [ ${docker} -eq 1 ]; then echo "Typecho"; fi
    if [ ${cloudreve} -eq 1 ]; then echo "Cloudreve"; fi
    if [ ${php} -eq 1 ]; then echo "php-fpm 7.3"; fi
    echo "---------------"
}

input(){
    if [ `expr ${filebrowser} + ${webdav} + ${aria2} + ${ariang} + ${syncthing} + ${typecho} + ${cloudreve}` -gt 0 ]; then read -p "请输入你的顶级域名：" domain_name; fi
    if [ ${webdav} -eq 1 ]; then read -p "请输入webdav账号：" webdav_user; fi
    if [ ${webdav} -eq 1 ]; then read -p "请输入webdav密码：" webdav_password; fi
    if [ ${aria2} -eq 1 ]; then read -p "请输入aria2的RPC密码：" aria2_password; fi
}

echo_domain_name(){
    echo "==========  ==========  =========="
    echo "需要用到的域名："
    if [ ${filebrowser} -eq 1 ]; then echo -e "FileBrowser:\t\tpan.${domain_name}"; fi
    if [ ${webdav} -eq 1 ]; then echo -e "webdav:\t\t\tdav.${domain_name}"; fi
    if [ ${aria2} -eq 1 ]; then echo -e "Aria2 RPC:\t\taria2.${domain_name}"; fi
    if [ ${ariang} -eq 1 ]; then echo -e "AriaNG:\t\t\tariang.${domain_name}"; fi
    if [ ${syncthing} -eq 1 ]; then echo -e "Syncthing:\t\tsync.${domain_name}"; fi
    if [ ${typecho} -eq 1 ]; then echo -e "Typecho:\t\tblog.${domain_name}"; fi
    if [ ${cloudreve} -eq 1 ]; then echo -e "Cloudreve:\t\tyun.${domain_name}"; fi
    echo "----------"
    echo "请提前做好解析"
    echo "脚本还未安装任何东西，输入 Y 开始安装，或者 Ctrl+C 终止"  
    echo "==========  ==========  =========="
}

confirm_install(){
    while true; do
        read -p "是否安装? [Y/n]" -n 1 yn
        case ${yn} in 
            y | Y ) echo -e "\n确定安装\n"; install; break;;
            n | N ) echo -e "\n已经退出安装\n"; exit 0;;
            * ) echo -e "\n请输入 \033[31mY\033[0m 或者 \033[31mn\033[0m";;
        esac
    done
}

install(){
    apt-get update
    apt-get upgrade -y
    if [ ${caddy} -eq 1 ]; then install_caddy; fi
    if [ ${filebrowser} -eq 1 ]; then install_filebrowser; fi
    if [ ${webdav} -eq 1 ]; then install_webdav; fi
    if [ ${aria2} -eq 1 ]; then install_aria2; fi
    if [ ${ariang} -eq 1 ]; then install_ariang; fi
    if [ ${syncthing} -eq 1 ]; then install_syncthing; fi
    if [ ${php} -eq 1 ]; then install_php; fi
    if [ ${typecho} -eq 1 ]; then install_typecho; fi
    if [ ${docker} -eq 1 ]; then install_docker; fi
    if [ ${cloudreve} -eq 1 ]; then install_cloudreve; fi
    sed -i "s/domain_name/${domain_name}/g" /etc/caddy/*.conf   
    check_firewall
    end
}

install_caddy(){
    wget -q -O /usr/local/bin/caddy 'https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fmholt%2Fcaddy-webdav&p=github.com%2Fcaddyserver%2Freplace-response&p=github.com%2Fcaddy-dns%2Falidns'
    chown root:root /usr/local/bin/caddy
    chmod 755 /usr/local/bin/caddy
    mkdir /etc/caddy
    mkdir /var/log/caddy
    mkdir /www
    curl -Ls ${url_repo}/etc/caddy/Caddyfile -o /etc/caddy/Caddyfile
    curl -Ls ${url_repo}/systemd/caddy.service -o /etc/systemd/system/caddy.service
    systemctl daemon-reload
    systemctl enable caddy
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：Caddy 安装完毕" >> ~/sh/install.log
}

install_filebrowser(){
    filebrowser_tag_name=`curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep 'tag_name' | cut -d\" -f4`
    wget -q https://github.com/filebrowser/filebrowser/releases/download/${filebrowser_tag_name}/linux-amd64-filebrowser.tar.gz
    mkdir ./filebrowser
    tar -xzvf linux-amd64-filebrowser.tar.gz -C ./filebrowser
    mv ./filebrowser/filebrowser /usr/local/bin
    chown root:root /usr/local/bin/filebrowser
    chmod 755 /usr/local/bin/filebrowser
    rm -rf ./filebrowser
    rm -f linux-amd64-filebrowser.tar.gz
    mkdir /etc/filebrowser
    filebrowser -d /etc/filebrowser/filebrowser.db config init
    filebrowser -d /etc/filebrowser/filebrowser.db config set --address 127.0.0.1 --port 2001 --locale zh-cn
    filebrowser -d /etc/filebrowser/filebrowser.db users add admin admin --perm.admin
    curl -Ls ${url_repo}/etc/caddy/pan.conf -o /etc/caddy/pan.conf
    curl -Ls ${url_repo}/systemd/filebrowser.service -o /etc/systemd/system/filebrowser.service
    systemctl daemon-reload
    systemctl enable filebrowser
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：FileBrowser 安装完毕" >> ~/sh/install.log
}

install_webdav(){
    webdav_password_hash=`caddy hash-password --plaintext ${webdav_password}`
    curl -Ls ${url_repo}/etc/caddy/dav.conf -o /etc/caddy/dav.conf
    sed -i "s/user/${webdav_user}/g" /etc/caddy/dav.conf
    sed -i "s/password/${webdav_password_hash}/g" /etc/caddy/dav.conf
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：webdav 安装完毕" >> ~/sh/install.log
}

install_aria2(){
    apt-get install aria2 -y
    mkdir /etc/aria2
    mkdir /var/log/aria2
    touch /var/log/aria2/aria2.log
    touch /var/log/aria2/aria2.session   
    curl -Ls ${url_repo}/etc/aria2/aria2.conf -o /etc/aria2/aria2.conf
    sed -i "s/rpc-secret=.*/rpc-secret=${aria2_password}/g" /etc/aria2/aria2.conf
    bt_tracker=$(echo `curl -s https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt` | sed "s/[ ]/,/g")
    sed -i "s#bt-tracker=.*#bt-tracker=${bt_tracker}#g" /etc/aria2/aria2.conf
    echo "# 自定义的tracker，必须一行一条的格式书写，更新tracker的脚本会把这些附加到网上获取的tracker后面" > /etc/aria2/tracker.txt
    curl -Ls ${url_repo}/aliyunlite-debian10.5/update-tracker.sh -o ~/sh/update-tracker.sh
    chmod 755 ~/sh/update-tracker.sh
    echo "0 5 * * * ~/sh/update-tracker.sh" >> /var/spool/cron/root
    curl -Ls ${url_repo}/etc/caddy/aria2.conf -o /etc/caddy/aria2.conf
    curl -Ls ${url_repo}/systemd/aria2.service -o /etc/systemd/system/aria2.service
    systemctl daemon-reload
    systemctl enable aria2
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：Aria2 安装完毕" >> ~/sh/install.log
}

install_ariang(){
    ariang_tag_name=`curl -s https://api.github.com/repos/mayswind/AriaNg/releases/latest | grep 'tag_name' | cut -d\" -f4`
    wget -q https://github.com/mayswind/AriaNg/releases/download/${ariang_tag_name}/AriaNg-${ariang_tag_name}.zip
    install_unzip
    unzip AriaNg-${ariang_tag_name}.zip -d /www/ariang
    rm -f AriaNg-${ariang_tag_name}.zip
    curl -Ls ${url_repo}/etc/caddy/ariang.conf -o /etc/caddy/ariang.conf
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：AriaNG 安装完毕" >> ~/sh/install.log
}

check_php(){
    if [ -z $(dpkg -l | awk '{if (NR > 5){print $2}}' | grep php-fpm) ]; then php=1; fi
}

install_php(){
    apt-get install php-fpm -y
    php_user_root
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：php-fpm 7.3 安装完毕" >> ~/sh/install.log
}

php_user_root(){
    sed -i "s#www-data#root#g" /etc/php/7.3/fpm/pool.d/www.conf
    sed -i "s#^ExecStart=/usr/sbin/php-fpm7.3 --nodaemonize#ExecStart=/usr/sbin/php-fpm7.3 --nodaemonize -R#g" /usr/lib/systemd/system/php7.3-fpm.service
    systemctl daemon-reload
    systemctl enable php-fpm
}

install_typecho(){
    apt-get install php-sqlite3 php-curl php-mbstring php-xml -y
    wget -q https://github.com/typecho/typecho/releases/latest/download/typecho.zip
    install_unzip
    unzip typecho.zip -d /www/blog
    rm -f typecho.zip
    curl -Ls ${url_repo}/etc/caddy/blog.conf -o /etc/caddy/blog.conf
    sed -i "s#unix//run/php-fpm/www.sock#unix//run/php/php7.3-fpm.sock#g" /etc/caddy/blog.conf
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：Typecho 安装完毕" >> ~/sh/install.log
}

install_docker() {
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg -y
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：Docker 安装完毕" >> ~/sh/install.log
}

install_syncthing(){
    syncthing_tag_name=`curl -s https://api.github.com/repos/syncthing/syncthing/releases/latest | grep 'tag_name' | cut -d\" -f4`
    wget -q https://github.com/syncthing/syncthing/releases/download/${syncthing_tag_name}/syncthing-linux-amd64-${syncthing_tag_name}.tar.gz
    tar -xzvf syncthing-linux-amd64-${syncthing_tag_name}.tar.gz
    mv ./syncthing-linux-amd64-${syncthing_tag_name}/syncthing /usr/local/bin/syncthing
    rm -f syncthing-linux-amd64-${syncthing_tag_name}.tar.gz
    rm -rf ./syncthing-linux-amd64-${syncthing_tag_name}
    chown root:root /usr/local/bin/syncthing
    chmod 755 /usr/local/bin/syncthing
    mkdir /etc/syncthing
    curl -Ls ${url_repo}/systemd/syncthing.service -o /etc/systemd/system/syncthing.service
    systemctl daemon-reload
    systemctl enable syncthing
    curl -Ls ${url_repo}/etc/caddy/sync.conf -o /etc/caddy/sync.conf
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：Syncthing 安装完毕" >> ~/sh/install.log
}

install_cloudreve(){
    cloudreve_tag_name=`curl -s https://api.github.com/repos/cloudreve/Cloudreve/releases/latest | grep 'tag_name' | cut -d\" -f4`
    wget -q https://github.com/cloudreve/Cloudreve/releases/download/${cloudreve_tag_name}/cloudreve_${cloudreve_tag_name}_linux_amd64.tar.gz
    tar -xzvf cloudreve_${cloudreve_tag_name}_linux_amd64.tar.gz -C /usr/local/bin
    rm -rf cloudreve_${cloudreve_tag_name}_linux_amd64.tar.gz
    chown root:root /usr/local/bin/cloudreve
    chmod 755 /usr/local/bin/cloudreve
    timeout 3 cloudreve | tee ~/sh/cloudreve.info
    cloudreve_password=`grep 初始管理员密码： ~/sh/cloudreve.info | cut -d' ' -f7`
    mkdir /etc/cloudreve
    mv /usr/local/bin/conf.ini /etc/cloudreve
    mv /usr/local/bin/cloudreve.db /etc/cloudreve
    sed -i "/Listen =.*/d" /etc/cloudreve/conf.ini
    echo "[UnixSocket]" >> /etc/cloudreve/conf.ini
    echo "Listen = /run/cloudreve.sock" >> /etc/cloudreve/conf.ini
    echo "[Database]" >> /etc/cloudreve/conf.ini
    echo "DBFile = /etc/cloudreve/cloudreve.db" >> /etc/cloudreve/conf.ini
    curl -Ls ${url_repo}/systemd/cloudreve.service -o /etc/systemd/system/cloudreve.service
    systemctl daemon-reload
    systemctl enable cloudreve
    curl -Ls ${url_repo}/etc/caddy/yun.conf -o /etc/caddy/yun.conf
    time=$(date +%Y/%m/%d-%T)
    echo "${time}：Cloudreve 安装完毕" >> ~/sh/install.log
}

install_unzip(){
    if [ -z $(dpkg -l | awk '{if (NR > 5){print $2}}' | grep -w -i unzip) ]; then apt-get install unzip -y; fi
}

check_firewall(){
    if [[ $(ufw status) != 'Status: inactive' ]]; then
        if [ ${caddy} -eq 1 ]; then ufw allow http && ufw allow https; fi
        if [ ${aria2} -eq 1 ]; then ufw allow 3001/tcp && ufw allow 3001/udp; fi
        if [ ${syncthing} -eq 1 ]; then ufw allow 22000/tcp && ufw allow 22000/udp; fi
    fi
}

end(){
    ip=`curl ifconfig.me`
    info_caddy="Caddy 已安装
配置文件在/etc/caddy，如有需要，自行修改
---------- ---------- ----------"

    info_filebrowser="FileBrowser 已安装
网址：https://pan.${domain_name}
配置文件为/etc/caddy/pan.conf
db数据文件保存在/etc/filebrowser
默认账号：admin
默认密码：admin
---------- ---------- ----------"

    info_webdav="webdav 已安装
配置文件为/etc/caddy/dav.conf
地址为：https://dav.${domain_name}
账号：${webdav_user}
密码：${webdav_password}
---------- ---------- ----------"

    info_aria2="Aria2 已经安装
BT监听端口为：3001 请在防火墙放行 3001 tcp/udp 更好的进行BT下载
aria2 RPC地址为：https(wss)://aria2.${domain_name}:443/jsonrpc
密码：${aria2_password}
如果需要http或者ws连接aria2 RPC，请在防火墙放行6800端口
RPC地址为：http(ws)://${ip}:6800/jsonrpc
---------- ---------- ----------"

    info_ariang="AriaNG 已经安装
网址：https://ariang.${domain_name}
---------- ---------- ----------"

    info_syncthing="Syncthing 已安装
端口为：22000 请在防火墙放行 22000 tcp/udp
请打开 https://sync.${domain_name} 设置
---------- ---------- ----------"

    info_php="php-fpm 7.3 已经安装
用户和用户组：root:root !
监听：unix//run/php/php7.3-fpm.sock
---------- ---------- ----------"

    info_typecho="Typecho 已经安装
网址：https://blog.${domain_name}
自行设置
---------- ---------- ----------"

    info_docker="Docker 已经安装
---------- ---------- ----------"

    info_cloudreve="Cloudreve 已经安装
网址：https://yun.${domain_name}
初始管理员账号：admin@cloudreve.org
${cloudreve_password}
自行设置
---------- ---------- ----------"
    echo "---------- ---------- ----------" >> ~/sh/install.log
    if [ ${caddy} -eq 1 ]; then systemctl start caddy; fi
    if [ ${filebrowser} -eq 1 ]; then systemctl start filebrowser; fi
    if [ ${aria2} -eq 1 ]; then systemctl start aria2; fi
    if [ ${syncthing} -eq 1 ]; then systemctl start syncthing; fi
    if [ ${php} -eq 1 ]; then systemctl start php7.3-fpm; fi
    if [ ${cloudreve} -eq 1 ]; then systemctl start cloudreve; fi
    echo "---------- ---------- ----------"
    if [ ${caddy} -eq 1 ]; then echo "${info_caddy}"; fi
    if [ ${filebrowser} -eq 1 ]; then echo "${info_filebrowser}"; fi
    if [ ${webdav} -eq 1 ]; then echo "${info_webdav}"; fi
    if [ ${aria2} -eq 1 ]; then echo "${info_aria2}"; fi
    if [ ${ariang} -eq 1 ]; then echo "${info_ariang}"; fi
    if [ ${syncthing} -eq 1 ]; then echo "${info_syncthing}"; fi
    if [ ${php} -eq 1 ]; then echo "${info_php}"; fi
    if [ ${typecho} -eq 1 ]; then echo "${info_typecho}"; fi
    if [ ${typecho} -eq 1 ]; then echo "${info_docker}"; fi
    if [ ${cloudreve} -eq 1 ]; then echo "${info_cloudreve}"; fi
}

run "$@"
