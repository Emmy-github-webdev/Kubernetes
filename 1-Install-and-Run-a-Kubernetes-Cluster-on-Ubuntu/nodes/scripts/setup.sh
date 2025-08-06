#!/bin/bash

# Set hostname
hostnamectl set-hostname ${hostname}

# Update /etc/hosts to reflect the new hostname
echo "127.0.1.1 ${hostname}" >> /etc/hosts

# Disable the swap settings
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install Containerd
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Load the kernel modules immediately
modprobe overlay
modprobe br_netfilter

# Enable the IPv6 settings
cat <<EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Install Kubernetes Components
# Add Kubernetes Repositories to the Instance
apt-get update
curl -fsSL https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt update

# Install kubeadm, kubelet, and kubectl
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Set Containerd as Default
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml > /dev/null
systemctl restart containerd

# For only master node
if [ "${role}" = "master" ]; then
  # Intializing kubernetes Master Node
  echo "Intializing kubernetes Master Node..."
  kubeadm init --pod-network-cidr=10.244.0.0/16

  # Setuping kubeconfig for the master node
  echo "Setuping kubeconfig for the master node..."
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config

  # setup the CNI as flannel for the kubernetes cluster
  echo "setup the CNI as flannel for the kubernetes cluster..."
  kubectl apply -f https://github.com/coreos/flannel/releases/download/v0.20.2/kube-flannel.yml

  # Join Worker Nodes
  echo "Join Worker Nodes..."
  kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
  
  # Verify the Kubernetes Cluster
  echo "Verify the Kubernetes Cluster..."
  kubectl get nodes

  # Check the K8s Resources
  echo "Checking the K8s Resources"
  kubectl get all -n kube-system

  # Create Pod Application
  echo "Creating Pod Application..."

  # Create a service for this pod
  echo "Creating a service for this pod..."
  kubectl expose pod mypod1 --type=NodePort --port=80 --target-port=8080
fi