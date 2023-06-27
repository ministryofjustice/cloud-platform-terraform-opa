terraform {
  required_version = ">= 1.2.5"
}


resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "16.14.1"
  namespace  = "monitoring"
  depends_on = [kubernetes_namespace.monitoring]

  set {
    name  = "defaultRules.create"
    value = "false"
  }
  set {
    name  = "alertmanager.enabled"
    value = "false"
  }
  set {
    name  = "grafana.enabled"
    value = "false"
  }
  set {
    name  = "kubeApiServer.enabled"
    value = "false"
  }
  set {
    name  = "kubelet.enabled"
    value = "false"
  }
  set {
    name  = "kubeControllerManager.enabled"
    value = "false"
  }
  set {
    name  = "coreDns.enabled"
    value = "false"
  }
  set {
    name  = "kubeDns.enabled"
    value = "false"
  }
  set {
    name  = "kubeEtcd.enabled"
    value = "false"
  }
  set {
    name  = "kubeScheduler.enabled"
    value = "false"
  }
  set {
    name  = "kubeProxy.enabled"
    value = "false"
  }
  set {
    name  = "kubeStateMetrics.enabled"
    value = "false"
  }
  set {
    name  = "nodeExporter.enabled"
    value = "false"
  }
  set {
    name  = "prometheusOperator.enabled"
    value = "false"
  }
  set {
    name  = "prometheus.enabled"
    value = "true"
  }

}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.4.0"
  namespace  = "cert-manager"
  depends_on = [kubernetes_namespace.cert_manager, helm_release.prometheus]

  set {
    name  = "installCRDs"
    value = "true"
  }
}

module "opa" {
  source              = "../.."
  depends_on          = [helm_release.cert_manager]
  cluster_domain_name = "opa.cloud-platform.service.justice.gov.uk"
}
