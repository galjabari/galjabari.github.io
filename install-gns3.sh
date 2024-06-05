#! /bin/sh
## Install GNS3
sudo add-apt-repository ppa:gns3/ppa -y
sudo apt update
sudo apt install gns3-gui gns3-server -y
#sudo dpkg --add-architecture i386
#sudo apt update
#sudo apt install gns3-iou -y
sudo apt install tigervnc-standalone-server tigervnc-viewer -y 
## Install Docker
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
sudo apt-get install curl -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
sudo apt update
sudo apt install docker-ce -y
sudo usermod -aG docker $(whoami)
