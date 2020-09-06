#!/usr/bin/env bash

# Login to super user first
######################
# su -
######################

#Install Docker
echo "-- [Kubernetes Installation] --"
echo "-- [Kubernetes Installation: Start Process] --"

#Make sure that all ports k8s uses are open by 
#1) Disable firewall (to allow all ports) 
#2) or Open ports that k8s uses
#####Choice 1
#systemctl stop firewalld
#systemctl disable firewalld

#####Choice2
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd –reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#Disable swap
swapoff -a
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

#Disable SELinux
setenforce 0
sed -i 's/enforcing/disabled/g' /etc/selinux/config

#Kubernetes Repository
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

dnf update -y

#Install all the necessary components for Kubernetes
dnf install -y kubelet-1.18.0-0 kubeadm-1.18.0-0 kubectl-1.18.0-0 kubernetes-cni --disableexcludes=kubernetes --nobest

#Start k8s
systemctl enable kubelet
systemctl start kubelet

#Hold update
echo "exclude=kubelet* kubeadm* kubectl*" >> /etc/dnf/dnf.conf
echo "exclude=kubelet* kubeadm* kubectl*" >> /etc/yum.conf

#Set bridged packets to traverse iptables rules
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
	
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.ipv4.ip_forward=1
sysctl --system
echo "1" > /proc/sys/net/ipv4/ip_forward

systemctl daemon-reload
systemctl restart kubelet

#Show version
echo "-- [Version of kubectl] --"
kubectl version --client=true
echo ""
echo "-- [Version of kubelet] --"
kubelet --version
echo ""
echo "-- [Version of kubeadm] --"
kubeadm version
echo ""

echo "-- [Kubernetes Installation: End Process] --"

##########################################