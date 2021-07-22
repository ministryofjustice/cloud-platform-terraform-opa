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

module "prometheus" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-monitoring?ref=1.7.2"

  alertmanager_slack_receivers = [
    {
      severity = "warning"
      webhook  = "https://hooks.slack.com/services/XXXXX/XXXX/XXXXX"
      channel  = "#lower-priority-alarms"
  }]

  iam_role_nodes                             = "arn:aws:iam::000000000000:role/dummy"
  pagerduty_config                           = "dummy"
  enable_ecr_exporter                        = false
  enable_cloudwatch_exporter                 = false
  enable_thanos_helm_chart                   = false
  enable_thanos_sidecar                      = false
  enable_prometheus_affinity_and_tolerations = false

  cluster_domain_name           = "opa.cloud-platform.service.justice.gov.uk"
  oidc_components_client_id     = "dummy"
  oidc_components_client_secret = "dummmy"
  oidc_issuer_url               = "https://justice-cloud-platform.eu.auth0.com/"
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

  cluster_domain_name = "opa.cloud-platform.service.justice.gov.uk"
}
