#!/usr/bin/env bash

echo 'Updating and Removing unnessary packages'

sudo apt-get update -y
sudo apt-get install net-tools -y
sudo apt-get install xrdp -y
sudo apt-get install openvpn -y
sudo apt-get remove --purge '*libreoffice*' -y
sudo apt-get clean -y
sudo apt-get autoremove -y

echo "Process Completed successfully"
