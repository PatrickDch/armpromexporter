#!/bin/bash
###################################
# Setup Prometheus Nodeexporter for arm(non 64 bit) SoC
# PatrickDch
# Matrix https://matrix.to/#/@pdombrow:matrix.org
# Comment: That is indeed a really fast written script to fast setup the core
###################################
echo "Are you using 64 bit soc? (N/y)"
read socv
socv=${socv:n}
echo "Which nodeexporter version you need?(default is 1.3.1)"
read nev
nev=${nev:131}
case $nev in

  131)
    
    url="1.3.1"
    ;;

  *)
    
    url=$nev
    ;;

esac

case $socv in

  y)
    echo "Downloading the arm64 version"
    wget https://github.com/prometheus/node_exporter/releases/download/v$nev/node_exporter-$nev.linux-armv64.tar.gz
    ;;

  n)
    echo "Downloading the arm version"
    wget https://github.com/prometheus/node_exporter/releases/download/v$nev/node_exporter-$nev.linux-armv6.tar.gz
    ;;

esac

echo "GoProxy or nginx? (G/n)"
read prox 
prox=${prox:g}
case $socv in

  g)
    echo "Deploying GoProxy"
    echo " [Unit]
    Description=GoHttp
    After=network.target
    ConditionPathExists=/data/cert

    [Service]
    Type=simple

    Restart=on-failure
    RestartSec=10

    ExecStart=/usr/local/bin/server

    [Install]
    WantedBy=multi-user.target" > /etc/systemd/system/gohttp.service
    sleep 2
    sudo go env -w GO111MODULE=auto
    mkdir -p /opt/gobuild
    cp -rv ./httpsexporter.go /opt/gobuild/
    cd /opt/gobuild &&  sudo go get -v github.com/abbot/go-http-auth
    cd /opt/gobuild &&  sudo go get -v github.com/keep94/weblogs
    cd /opt/gobuild &&  sudo go get -v github.com/gorilla/context
    cd /opt/gobuild &&  sudo go build httpsexporter.go && sudo mv -vf httpsexporter /usr/local/bin/server
    rm -rf /opt/gobuild
    systemctl daemon-reload
    sleep 2 
    systemctl restart gohttp.service
    sleep 2
    netstat -tnlp 
    sleep 2
    systemctl enable --now gohttp.service
    ;;

  n)
    echo "nginx config deployment"
    cp -v ./nginx/default /etc/nginx
    ;;

esac
rm /opt/nodeexport/ -rf
cd /opt
sleep 2
mkdir nodeexport; cd nodeexport
sleep 2
useradd -M -r -s /bin/false node_exporter
sleep 2
tar xvfz node_exporter-*.tar.gz
sleep 2 
cp node_exporter-*/node_exporter /usr/local/bin/ -v
sleep 2
chown node_exporter:node_exporter /usr/local/bin/node_exporter
sleep 2
mkdir -p /data/cert
openssl genrsa -out /data/cert/server.key 2048
sleep 2
openssl ecparam -genkey -name secp384r1 -out /data/cert/server.key
sleep 2
openssl req -x509 -nodes -sha256 -days 3650 -subj "/C=local/ST=local/O=local/CN=127.0.0.1" -addext "subjectAltName=IP:127.0.0.1" -key /data/cert/server.key -out /data/cert/server.crt;
cp -v  ./nginx/.htpasswd /data/


echo "
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=127.0.0.1:9100 --collector.cpu --collector.meminfo --collector.loadavg --collector.filesystem

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node_exporter.service
sleep 2
systemctl daemon-reload
sleep 2 
systemctl restart node_exporter.service
sleep 2
netstat -tnlp 
sleep 2
systemctl enable --now node_exporter.service
sleep 3
ss -altnp | grep 91