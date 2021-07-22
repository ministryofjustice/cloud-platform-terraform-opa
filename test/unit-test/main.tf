terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region = "eu-west-2"
}

module "cert_manager" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-certmanager?ref=1.2.1"
  cluster_domain_name = "opa.cloud-platform.service.justice.gov.uk"
  eks                 = false
}

module "opa" {
  source = "../.."

  cluster_domain_name = "opa.cloud-platform.service.justice.gov.uk"
}
