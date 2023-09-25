terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.0.12"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "default" {
  name = "cluster-1"
  wait_for_ready = true
  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }

    node {
      role = "worker"
      image = "kindest/node:v1.23.4"
    }

    node {
      role = "worker"
      image = "kindest/node:v1.23.4"
    }

    node {
      role = "worker"
      image = "kindest/node:v1.23.4"
    }
  }
}

provider "kubectl" {
  host = "${kind_cluster.default.endpoint}"
  cluster_ca_certificate = "${kind_cluster.default.cluster_ca_certificate}"
  client_certificate = "${kind_cluster.default.client_certificate}"
  client_key = "${kind_cluster.default.client_key}"
}

#data "kubectl_file_documents" "crds" {
#  content = file("olm/crds.yaml")
#}
#
#resource "kubectl_manifest" "crds_apply" {
#  for_each  = data.kubectl_file_documents.crds.manifests
#  yaml_body = each.value
#  wait = true
#  server_side_apply = true
#}
#
#data "kubectl_file_documents" "olm" {
#  content = file("olm/olm.yaml")
#}
#
#resource "kubectl_manifest" "olm_apply" {
#  depends_on = [data.kubectl_file_documents.crds]
#  for_each  = data.kubectl_file_documents.olm.manifests
#  yaml_body = each.value
#}

provider "helm" {
  kubernetes {
    host = "${kind_cluster.default.endpoint}"
    cluster_ca_certificate = "${kind_cluster.default.cluster_ca_certificate}"
    client_certificate = "${kind_cluster.default.client_certificate}"
    client_key = "${kind_cluster.default.client_key}"
  }
}

resource "helm_release" "olm" {
  name = "olm"

  repository       = "https://risserlabs.gitlab.io/community/charts"
  chart            = "olm"
  namespace        = "olm"
  version          = "0.25.0"
  create_namespace = true
}

resource "helm_release" "argocd" {
  name  = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "4.9.7"
  create_namespace = true

  values = [
    file("argocd/application.yaml")
  ]

  depends_on = [helm_release.olm]
}