#!/bin/bash

set -x

# 指定 Kubernetes 版本
KUBERNETES_VERSION="1.24.0"

# 检查是否已安装 blkio cgroup
if ! grep -q "cgroup_enable=blkio" /etc/default/grub; then
  # 安装 blkio cgroup
  sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ cgroup_enable=blkio"/' /etc/default/grub
  sudo update-grub

  # 提示需要重启系统
  echo "安装 blkio cgroup 需要重启系统"
  sudo reboot
fi



# 更新系统后继续执行脚本

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/kubernetes.list <<-'EOF'
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# 指定 kubeadm、kubelet 和 kubectl 的版本
KUBEADM_VERSION="$KUBERNETES_VERSION-00"
KUBELET_VERSION="$KUBERNETES_VERSION-00"
KUBECTL_VERSION="$KUBERNETES_VERSION-00"

# 获取本地 IP 地址
local_ip=$(ip -o -4 addr show up primary scope global | awk '{print $4}' | cut -d '/' -f 1 | head -n 1)

# 检查是否找到本地 IP 地址
if [ -z "$local_ip" ]; then
  echo "无法找到本地 IP 地址"
  exit 1
fi

# 安装 Docker
sudo apt-get install -y docker.io

# 安装 kubeadm、kubelet 和 kubectl 特定版本
sudo apt-get install -y kubeadm=$KUBEADM_VERSION kubelet=$KUBELET_VERSION kubectl=$KUBECTL_VERSION

# 配置 Docker Cgroup 驱动程序为 systemd
sudo sed -i '/\[Service\]/a ExecStartPost=\/sbin\/iptables -P FORWARD ACCEPT' /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker

# 初始化 Kubernetes 主节点
sudo kubeadm init --apiserver-advertise-address=$local_ip --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v$KUBERNETES_VERSION

# 配置 Kubernetes 集群
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://docs.projectcalico.org/archive/v3.19/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/archive/v3.19/manifests/custom-resources.yaml
# 打印加入节点的命令
join_command=$(kubeadm token create --print-join-command)
echo "保存下面的加入节点命令以便后续使用："
echo "$join_command"
