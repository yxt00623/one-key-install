#!/bin/bash

set -x

# 指定 Kubernetes 版本
KUBERNETES_VERSION="1.23.0"

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -

sudo tee /etc/apt/sources.list.d/kubernetes.list <<-'EOF'
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF


# 指定 kubeadm、kubelet 和 kubectl 的版本
KUBEADM_VERSION="$KUBERNETES_VERSION-00"
KUBELET_VERSION="$KUBERNETES_VERSION-00"
KUBECTL_VERSION="$KUBERNETES_VERSION-00"

sudo apt-get update
sudo apt-get install -y kubeadm=$KUBEADM_VERSION kubelet=$KUBELET_VERSION kubectl=$KUBECTL_VERSION
sudo apt-mark hold kubelet kubeadm kubectl


# 获取本地 IP 地址
local_ip=$(ip -o -4 addr show up primary scope global | awk '{print $4}' | cut -d '/' -f 1 | head -n 1)

# 检查是否找到本地 IP 地址
if [ -z "$local_ip" ]; then
  echo "无法找到本地 IP 地址"
  exit 1
fi

# 安装 Docker
sudo apt-get install -y docker.io

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF


systemctl daemon-reload
systemctl restart docker


sudo kubeadm init --image-repository registry.aliyuncs.com/google_containers  --apiserver-advertise-address=$local_ip --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v$KUBERNETES_VERSION


# 配置 Kubernetes 集群
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl taint nodes --all node-role.kubernetes.io/master-


kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml



# 打印加入节点的命令
join_command=$(kubeadm token create --print-join-command)
echo "保存下面的加入节点命令以便后续使用："
echo "$join_command"
