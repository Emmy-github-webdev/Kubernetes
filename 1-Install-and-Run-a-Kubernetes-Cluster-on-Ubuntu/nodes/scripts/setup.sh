#!/bin/bash

# Set hostname
#hostnamectl set-hostname ${hostname}

# Update /etc/hosts to reflect the new hostname
#echo "127.0.1.1 ${hostname}" >> /etc/hosts

# Disable the swap settings
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install Containerd
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Load the kernel modules immediately
sudo modprobe overlay
sudo modprobe br_netfilter

# Enable the IPv6 settings
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Install Kubernetes Components
# Add Kubernetes Repositories to the Instance
sudo apt-get update
curl -fsSL https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update

# Install kubeadm, kubelet, and kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Set Containerd as Default
sudo mkdir -p /etc/containerd
sudo apt install -y containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo systemctl restart containerd
systemctl status containerd



# For only master node
if [ "${role}" = "master" ]; then
  # Intializing kubernetes Master Node
  echo "Intializing kubernetes Master Node..."
  # For testing purpose only
  sudo kubeadm init --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=Mem,FileContent--proc-sys-net-ipv4-ip_forward

  # Setuping kubeconfig for the master node
  echo "Setuping kubeconfig for the master node..."
  sudo mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  # setup the CNI as flannel for the kubernetes cluster
  echo "setup the CNI as flannel for the kubernetes cluster..."
  kubectl apply -f https://github.com/coreos/flannel/releases/download/v0.20.2/kube-flannel.yml

  # Join Worker Nodes
  echo "Join Worker Nodes..."
  # kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
  # How to get the real value - kubeadm token create --print-join-command
  kubeadm join 172.31.39.8:6443 --token gkhryh.k55atakut4z7vnd1 --discovery-token-ca-cert-hash sha256:17c3413311de0a6a28ad5c7216b7ae3ce776a560f1d77eefabf899b8e19f1f84
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