#!/bin/bash

# 01 init cluster
echo 1 > /proc/sys/net/ipv4/ip_forward

kubeadm init \
  --cri-socket /run/containerd/containerd.sock \
  --pod-network-cidr=192.168.0.0/16

# 02 copy kubeconfig
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# 03 install cni

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml
sleep 5 #wait for the deployment to start the required pods
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml
sleep 5 #wait for the deployment to start the required pods