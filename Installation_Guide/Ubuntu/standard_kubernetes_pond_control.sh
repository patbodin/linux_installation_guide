#!/usr/bin/env bash

#Should change to su first
#sudo su -

#Set LC_ALL, LANG
sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locate
sudo echo "LANG=en_US.UTF-8" >> /etc/default/locate

#tuning sysctl.conf
sudo echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf
sudo echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_rmem = 4096 87380 16777216" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_wmem = 4096 65536 16777216" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_keepalive_probes = 9" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_keepalive_time = 7200" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_syn_retries = 5" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_no_metrics_save = 1" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_syn_retries = 2" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_tw_reuse=1" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_fin_timeout=15" >> /etc/sysctl.conf
sudo echo "net.ipv4.ip_local_port_range = 2000 65000" >> /etc/sysctl.conf
sudo echo "fs.file-max = 1000000" >> /etc/sysctl.conf
sudo echo "vm.swappiness = 0" >> /etc/sysctl.conf
sudo echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf

#tuning limits.conf
sudo echo "* soft    nproc    65535" >> /etc/security/limits.conf
sudo echo "* hard    nproc    65535" >> /etc/security/limits.conf
sudo echo "* soft    nofile   65535" >> /etc/security/limits.conf
sudo echo "* hard    nofile   65535" >> /etc/security/limits.conf
sudo echo "root soft    nproc    65535" >> /etc/security/limits.conf  
sudo echo "root hard    nproc    65535" >> /etc/security/limits.conf
sudo echo "root soft    nofile   65535" >> /etc/security/limits.conf
sudo echo "root hard    nofile   65535" >> /etc/security/limits.conf

#create 1001 user
sudo useradd -u 1001 --no-create-home 1001
sudo mkdir -p /var/www && sudo chown 1001:1001 /var/www
sudo mkdir -p /var/dockers && sudo chown 1001:1001 /var/dockers

#install docker
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
#sudo apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo apt update && apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
### Add Docker’s official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
### Add Docker apt repository.
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
## Install Docker CE.
#sudo apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
sudo apt update && apt install docker-ce docker-ce-cli containerd.io && apt-mark hold docker-ce

sudo usermod -aG docker $USER
sudo usermod -aG docker poseidon

# Setup daemon.
sudo cat > /etc/docker/daemon.json <<EOF
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

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

#install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
#add ubuntu and 1001 to docker group
sudo usermod -a -G docker ubuntu
sudo usermod -a -G docker 1001

#Change mode for /var/run/docker.sock
sudo chmod 666 /var/run/docker.sock

#Ensure iptables tools does not use the nftables backend
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

#Install Kubernetes Base
#sudo apt-get update && sudo apt-get install -y apt-transport-https curl
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt update
#sudo apt-get install -y kubectl=1.18.0-00 kubelet=1.18.0-00 kubeadm=1.18.0-00 kubectl=1.18.0-00 kubernetes-cni && apt-mark hold kubelet kubeadm kubectl
sudo apt install kubectl=1.18.0-00 kubelet=1.18.0-00 kubeadm=1.18.0-00 kubectl=1.18.0-00 kubernetes-cni && apt-mark hold kubelet kubeadm kubectl
#sudo apt install kubectl kubelet kubeadm kubectl kubernetes-cni && apt-mark hold kubelet kubeadm kubectl
#sudo snap install kubectl --classic
#sudo snap install kubelet --classic
#sudo snap install kubeadm --classic
#sudo apt install kubernetes-cni --classic
#sudo apt-mark hold kubelet kubeadm kubectl
#restart
#reboot

#Disable swap
#sudo swapoff -a
