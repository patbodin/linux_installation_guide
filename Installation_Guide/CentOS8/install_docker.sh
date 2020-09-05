#!/usr/bin/env bash

# Login to super user first
######################
# su -
######################

#Install Docker
echo "-- [Docker & Docker-Compose Installation] --"
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
systemctl enable docker

#Show version of docker installed
docker version

#Change mode of poseidon user
usermod -aG docker poseidon

#Setup daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "10"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

#Restart docker
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

#Change mode of docker.sock
chmod 666 /var/run/docker.sock

echo "-- [Docker Installation: End Process] --"
echo "-- [Docker-Compose Installation: Start Process] --"

#Install docker-compose
dnf install curl -y

curl -L https://github.com/docker/compose/releases/download/1.25.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

#Show docker-compose version
docker-compose --version

echo "-- [Docker-Compose Installation: End Process] --"

##########################################