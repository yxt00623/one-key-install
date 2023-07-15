#!/bin/bash

set -x

# 关闭防火墙
# sudo ufw disable 
# 正常安装
# curl -sfL https://get.k3s.io | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.23.17+k3s1 sh -

# 网络不好安装
# https://github.com/k3s-io/k3s/releases/tag/v1.23.4%2Bk3s1
gunzip k3s-airgap-images-amd64.tar.gz #解压缩
sudo mkdir -p /var/lib/rancher/k3s/agent/images/
#  https://get.k3s.io 获取install脚本
chmod a+x k3s install.sh
sudo cp k3s-airgap-images-amd64.tar /var/lib/rancher/k3s/agent/images/
sudo cp k3s /usr/local/bin/

INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh



# 配置
# sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config
# 集群安装
# INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh --node-name master
# cat /var/lib/rancher/k3s/server/token
# 从节点加入
# INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://{masterip}:6443 K3S_TOKEN={token} ./install.sh --node-name slave-01

# 卸载
# /usr/local/bin/k3s-uninstall.sh
