#!/bin/bash
# This script creates a kubernetes with version

set -xe

MASTER_NODE_IP=10.82.45.41

echo y | kubeadm reset

systemctl restart kubelet.service
systemctl status kubelet.service

kubeadm init --kubernetes-version=v1.11.0 --apiserver-advertise-address ${MASTER_NODE_IP} --pod-network-cidr=10.244.0.0/16

echo y | cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

chown $(id -u):$(id -g) $HOME/.kube/config

echo "source <(kubectl completion bash)" >> ~/.bashrc

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

