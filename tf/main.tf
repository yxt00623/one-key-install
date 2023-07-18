terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
  }
}

resource "helm_release" "my_nginx" {
  name       = "my-nginx"
  repository = "local"
  chart      = "./charts/my-nginx-chart-0.1.0.tgz"
  version    = ""
  namespace  = "default"

  values = [
    <<EOF
{
  "domain": "${var.domain}"
}
EOF
  ]
}