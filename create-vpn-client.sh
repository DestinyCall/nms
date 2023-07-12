#!/usr/bin/env bash

echo 'Creating and configuring openvpn client service'

sudo cp /home/agent/agent2.ovpn /etc/openvpn
sudo cp /etc/openvpn/agent2.ovpn /etc/openvpn/client.conf
sudo sed -i'.bak' '/verb/a \comp-lzo' /etc/openvpn/client.conf

sudo systemctl enable openvpn@client.service
sudo systemctl daemon-reload
sudo service openvpn@client start

echo "Openvpn client config success"
