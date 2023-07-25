#!/bin/bash

set -x

# 关闭防火墙
# sudo ufw disable 
# 正常安装
# curl -sfL https://get.k3s.io | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.23.17+k3s1 sh -



# docker 私有仓库
mkdir -p /etc/docker
echo '{"insecure-registries": ["registry.wll:5000"],"registry-mirrors":["https://docker.mirrors.ustc.edu.cn"]}' | sudo tee /etc/docker/daemon.json
# 安装docker
sudo apt update
sudo apt install -y docker.io
# echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
# sudo apt update
# sudo apt install -y docker-ce docker-ce-cli containerd.io
# sudo systemctl start docker

# 看是否需要修改
# vi /etc/systemd/system/k3s.service



# 网络不好安装
# https://github.com/k3s-io/k3s/releases/tag/v1.23.4%2Bk3s1
gunzip k3s-airgap-images-amd64.tar.gz #解压缩
sudo ufw disable

#  https://get.k3s.io 获取install脚本


sudo mkdir -p /var/lib/rancher/k3s/agent/images/
chmod a+x k3s install.sh
sudo cp k3s-airgap-images-amd64.tar /var/lib/rancher/k3s/agent/images/
sudo cp k3s /usr/local/bin/


# 主节点
export INSTALL_K3S_EXEC="--docker"
INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh --node-name master 

sudo cat /var/lib/rancher/k3s/server/node-token


# 从节点

# export K3S_URL=https://<主节点的 IP 地址>:6443
# export K3S_TOKEN=<主节点授权令牌>
# curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_DOWNLOAD=true sh -s - --docker --node-name master

export K3S_URL=https://172.16.22.177:6443
export K3S_TOKEN=K102430eb87e174935f334d52b1dd5b5 -ef |grep3961f59344e245fb45a4673a0b84a690894::server:e8f5184665038f740b8ac5e57de8d3c6

export INSTALL_K3S_EXEC="--docker"
INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh --node-name node2

mkdir -p /root/.kube
sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config

# 查看错误
#journalctl -xe
# 配置
# sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config
# 集群安装
# INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh --node-name master
# cat /var/lib/rancher/k3s/server/token
# 从节点加入
# INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://{masterip}:6443 K3S_TOKEN={token} ./install.sh --node-name slave-01

# 卸载
# /usr/local/bin/k3s-uninstall.sh




# docker run --name mysql57 -e MYSQL_ROOT_PASSWORD=qwerty -p 23306:3306 -d mysql:5.7
# helm pull stable/mysql --untar
# kubectl port-forward svc/mysql 23306

# kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.2.2/deploy/longhorn.yaml