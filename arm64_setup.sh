###################################
# Setup Prometheus Nodeexporter for arm64 SoC
# PatrickDch
# Matrix https://matrix.to/#/@pdombrow:matrix.org
# Comment: That is indeed a really fast written script to fast setup the core
###################################
rm /opt/nodeexport/ -rf
cd /opt
sleep 2
mkdir nodeexport; cd nodeexport
sleep 2
useradd -M -r -s /bin/false node_exporter
sleep 2
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-armv64.tar.gz
sleep 2
tar xvfz node_exporter-*.tar.gz
sleep 2 
cp node_exporter-*/node_exporter /usr/local/bin/ -v
sleep 2
chown node_exporter:node_exporter /usr/local/bin/node_exporter
mkdir -p /data/cert
openssl genrsa -out /data/cert/server.key 2048
sleep 2
openssl ecparam -genkey -name secp384r1 -out /data/cert/server.key
sleep 2
openssl req -x509 -nodes -sha256 -days 3650 -subj "/C=BE/ST=BE/O=PDCH/CN=127.0.0.1" -addext "subjectAltName=IP:127.0.0.1" -key /data/cert/server.key -out /data/cert/server.crt;


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