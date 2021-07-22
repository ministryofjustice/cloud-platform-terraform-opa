terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region = "eu-west-2"
}

module "opa" {
  source = "../.."

  cluster_domain_name = "opa.cloud-platform.service.justice.gov.uk"
}
