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

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "12.11.3"
}

module "cert_manager" {
  source                = "github.com/ministryofjustice/cloud-platform-terraform-certmanager?ref=1.2.1"
  cluster_domain_name   = "opa.cloud-platform.service.justice.gov.uk"
  eks                   = false
  dependence_prometheus = "ignore"
  dependence_opa        = "ignore"
  iam_role_nodes        = "arn:aws:iam::000000000000:role/dummy"
  hostzone              = ["arn:aws:route53:::hostedzone/*"]
}

module "opa" {
  source = "../.."
  depends_on = [helm_release.prometheus_operator, module.cert_manager]
  cluster_domain_name = "opa.cloud-platform.service.justice.gov.uk"
}
