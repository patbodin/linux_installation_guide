#!/usr/bin/env bash

# Login to super user first
######################
# su -
######################

#Install Docker
echo "-- [Kubernetes Installation] --"
echo "-- [Kubernetes Installation: Start Process] --"

#Set bridged packets to traverse iptables rules
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
	
sysctl --system

swapoff -a

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

dnf update -y

#Install all the necessary components for Kubernetes
dnf install -y kubelet kubeadm kubectl kubernetes-cni --disableexcludes=kubernetes --nobest

#Start k8s
systemctl enable kubelet
systemctl start kubelet

#Hold update
echo "exclude=kubelet* kubeadm* kubectl*" >> /etc/dnf/dnf.conf
echo "exclude=kubelet* kubeadm* kubectl*" >> /etc/yum.conf

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