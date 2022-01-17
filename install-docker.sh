#!bin/bash

cd /tmp
sudo yum install wget -y
wget https://raw.githubusercontent.com/Genaker/Magento-AWS-Linux-2-Installation/master/install-docker.sh
bash ./install-docker.sh
