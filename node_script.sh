#!/bin/bash

# Enable ssh password authentication
echo "Enable SSH password authentication:"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "Set root password:"
echo -e "choclo123\nchoclo123" | passwd root >/dev/null 2>&1

# Upgrade
dnf -y upgrade
#Disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINX=enforcing/SELINX=disable/g' /etc/sysconfig/selinux

# Enable trasparent masquerading and facilitates VxLAN traffic for communication between K8s pods across the cluster
modprobe br_netfilter

#Enable IP masquerade on firewall
firewall-cmd --add-masquerade --permanent
firewall-cmd --reload

# Set bridge pkts to traverse iptable rules.
cat < /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#load new rules
sysctl --system

#Disable all memory swaps to increase performance
swapoff -a

#add repo for docker install
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

# Install containerd.io
dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm

#install docker
dnf install docker-ce --nobest -y

#Start docker
systemctl start docker

#start docker at startup
systemctl enable docker

#chang docker to use systemd cgroup driver
echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}' > /etc/docker/daemon.json

#restart docker
systemctl restart docker

# add k8s repo
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# update repo info
dnf update -y

# install k8s
dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# enable k8s and startup
systemctl enable kubelet
systemctl start kubelet
