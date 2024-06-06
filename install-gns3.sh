#! /bin/sh
sudo add-apt-repository ppa:gns3/ppa -y
sudo apt update
sudo apt install gns3-gui gns3-server -y
#sudo dpkg --add-architecture i386
#sudo apt update
#sudo apt install gns3-iou -y
sudo apt install tigervnc-standalone-server tigervnc-viewer -y
