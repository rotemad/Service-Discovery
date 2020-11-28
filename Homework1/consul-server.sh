#!/bin/bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update
apt-get install consul dnsmasq -y

cat << EOF >/etc/dnsmasq.d/10-consul
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF

systemctl restart dnsmasq

cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF

systemctl restart systemd-resolved.service

useradd consul
mkdir --parents /etc/consul.d
chown --recursive consul:consul /etc/consul.d

IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
cat << EOF > /etc/consul.d/server_config.json
{
  "advertise_addr": "$IP",
  "data_dir": "/opt/consul",
  "datacenter": "opsschool",
  "encrypt": "jrlBUPF89ipG6nVorTPL5zYy92/jGn4jWpSeX3zcAy8=",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul-server tag_value=true"],
  "server": true,
  "bootstrap_expect": 1,
  "ui": true,
  "client_addr": "0.0.0.0"
}
EOF
chown --recursive consul:consul /etc/consul.d/server_config.json
chmod 640 /etc/consul.d/server_config.json

touch /usr/lib/systemd/system/consul.service
cat << EOF > /usr/lib/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable consul
systemctl start consul