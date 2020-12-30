#!/bin/bash

sudo rm /var/lib/dpkg/lock-frontend; sudo rm /var/cache/apt/archives/lock;

sudo apt update

mkdir /home/$USER/Downloads/apps
cd /home/$USER/Downloads/apps


# Docker Installation:

sudo apt remove docker docker-engine docker.io containerd runc

sudo apt update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io


