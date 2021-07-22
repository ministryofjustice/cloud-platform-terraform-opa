terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  region                      = "eu-west-2"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    iam     = "http://localhost:4566"
    route53 = "http://localhost:4566"
    sts     = "http://localhost:4566"
  }
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
  version    = "17.0.0"
  namespace  = "monitoring"
  depends_on = [kubernetes_namespace.monitoring]

  set {
    name = "defaultRules.create"
    value = "false"
  }
  set {
    name = "alertmanager.enabled"
    value = "false"
  }
  set {
    name = "grafana.enabled"
    value = "false"
  }
  set {
    name = "kubeApiServer.enabled"
    value = "false"
  }
  set {
    name = "kubelet.enabled"
    value = "false"
  }
  set {
    name = "kubeControllerManager.enabled"
    value = "false"
  }
  set {
    name = "coreDns.enabled"
    value = "false"
  }
  set {
    name = "kubeDns.enabled"
    value = "false"
  }
  set {
    name = "kubeEtcd.enabled"
    value = "false"
  }
  set {
    name = "kubeScheduler.enabled"
    value = "false"
  }
  set {
    name = "kubeProxy.enabled"
    value = "false"
  }
  set {
    name = "kubeStateMetrics.enabled"
    value = "false"
  }
  set {
    name = "nodeExporter.enabled"
    value = "false"
  }
  set {
    name = "prometheusOperator.enabled"
    value = "false"
  }
  set {
    name = "prometheus.enabled"
    value = "false"
  }

}

module "cert_manager" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-certmanager?ref=1.2.1"
  cluster_domain_name   = "opa.cloud-platform.service.justice.gov.uk"
  eks                   = false
  dependence_prometheus = "ignore"
  dependence_opa        = "ignore"
  iam_role_nodes        = "arn:aws:iam::000000000000:role/dummy"
  hostzone              = ["arn:aws:route53:::hostedzone/*"]
  depends_on            = [helm_release.prometheus]
}

module "opa" {
  source              = "../.."
  depends_on          = [module.cert_manager]
  cluster_domain_name = "opa.cloud-platform.service.justice.gov.uk"
}
