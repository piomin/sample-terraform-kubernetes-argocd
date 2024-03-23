terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "default" {
  name = var.cluster_name
  wait_for_ready = true
  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    node {
      role = "worker"
      image = "kindest/node:v1.27.1"
    }

    node {
      role = "worker"
      image = "kindest/node:v1.27.1"
    }

    node {
      role = "worker"
      image = "kindest/node:v1.27.1"
    }
  }
}

provider "kubectl" {
  host = kind_cluster.default.endpoint
  cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
  client_certificate = kind_cluster.default.client_certificate
  client_key = kind_cluster.default.client_key
}

data "kubectl_file_documents" "crds" {
  content = file("olm/crds.yaml")
}

resource "kubectl_manifest" "crds_apply" {
  for_each  = data.kubectl_file_documents.crds.manifests
  yaml_body = each.value
  wait = true
  server_side_apply = true
}

data "kubectl_file_documents" "olm" {
  content = file("olm/olm.yaml")
}

resource "kubectl_manifest" "olm_apply" {
  depends_on = [kubectl_manifest.crds_apply]
  for_each  = data.kubectl_file_documents.olm.manifests
  wait = true
  yaml_body = each.value
}

data "kubectl_file_documents" "final" {
  content = file("olm/final.yaml")
}

resource "kubectl_manifest" "final_apply" {
  depends_on = [kubectl_manifest.olm_apply]
  for_each  = data.kubectl_file_documents.final.manifests
  wait = true
  yaml_body = each.value
}

provider "helm" {
  kubernetes {
    host = kind_cluster.default.endpoint
    cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
    client_certificate = kind_cluster.default.client_certificate
    client_key = kind_cluster.default.client_key
  }
}

resource "time_sleep" "wait_150_seconds" {
  depends_on = [kubectl_manifest.final_apply]

  create_duration = "150s"
}

resource "helm_release" "argocd" {
  name  = "argocd"
  depends_on = [time_sleep.wait_150_seconds]

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "6.7.3"
  create_namespace = true

}

resource "helm_release" "argocd-apps" {
  name  = "argocd-apps"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-apps"
  namespace        = "argocd"
  version          = "2.0.0"

  values = [
    file("argocd/application.yaml")
  ]

  depends_on = [helm_release.argocd]
}