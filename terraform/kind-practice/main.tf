terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.9.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "kind" {
  # Configuration options
}

resource "kind_cluster" "default" {
  name           = "test-cluster"
  kubeconfig_path = pathexpand("./test-cluster-config")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = 30080
        host_port      = 8080
        listen_address = "0.0.0.0"
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 30443
        host_port      = 8443
        listen_address = "0.0.0.0"
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 30090
        host_port      = 9090
        listen_address = "0.0.0.0"
        protocol       = "TCP"
      }
    }
  }
}

provider "kubernetes" {
  config_path = kind_cluster.default.kubeconfig_path
}

provider "helm" {
  kubernetes = {
    config_path = kind_cluster.default.kubeconfig_path
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  timeout = 600  # 10 minutes timeout
  wait    = true

  values = [
    yamlencode({
      service = {
        type = "NodePort"
      }
      ports = {
        web = {
          nodePort = 30080
        }
        websecure = {
          nodePort = 30443
        }
      }
      api = {
        dashboard = true
        insecure = true
      }
      ingressRoute = {
        dashboard = {
          enabled = true
        }
      }
    })
  ]
}

# traefik 대시보드 연결
resource "kubernetes_service_v1" "traefik_dashboard" {
  metadata {
    name = "traefik-dashboard-service"
    namespace = "default"
  }
  spec {
    type = "NodePort"

    selector = {
      "app.kubernetes.io/name" = "traefik"
      "app.kubernetes.io/instance" = "traefik-default"
    }

    port {
      name = "dashboard"
      protocol = "TCP"
      port = 8080
      target_port = 8080
      node_port = 30090
    }
  }
}