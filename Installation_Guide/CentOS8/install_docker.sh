#!/usr/bin/env bash

# Login to super user first
######################
# su -
######################

#Install Docker
echo "-- [Docker Installation] --"
echo "-- [Docker Installation: Start Process] --"

#Setup repository
yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
	
#Install latest version
#yum install docker-ce docker-ce-cli containerd.io

#Install specific version
yum list docker-ce --showduplicates | sort -r

yum install docker-ce-3:18.09.1-3.el7 docker-ce-cli containerd.io

#Start docker
systemctl start docker

#Show version of docker installed
docker version

#Change mode of poseidon user
usermod -aG docker poseidon

#Change mode of docker.sock
chmod 666 /var/run/docker.sock

echo "-- [Docker Installation: End Process] --"

##########################################