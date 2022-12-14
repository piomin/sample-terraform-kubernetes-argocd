# Sealed Secrets Installation

resource "kubernetes_namespace" "sealed-secrets-ns" {
  metadata {
    name = "sealed-secrets"
  }
}

resource "kubernetes_secret" "sealed-secrets-key" {
  depends_on = [kubernetes_namespace.sealed-secrets-ns]
  metadata {
    name      = "sealed-secrets-key"
    namespace = "sealed-secrets"
  }
  data = {
    "tls.crt" = file("keys/tls.crt")
    "tls.key" = file("keys/tls.key")
  }
  type = "kubernetes.io/tls"
}

resource "helm_release" "sealed-secrets" {
  depends_on = [kubernetes_secret.sealed-secrets-key]
  chart      = "sealed-secrets"
  name       = "sealed-secrets"
  namespace  = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
}

# ArgoCD Installation

resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  create_namespace = true
}

resource "helm_release" "argocd-apps" {
  depends_on = [helm_release.argocd]
  chart      = "argocd-apps"
  name       = "argocd-apps"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  values = [
    file("argocd/applications.yaml")
  ]
}