
resource "kubernetes_namespace" "opa" {
  metadata {
    name = "opa"

    labels = {
      "name"                                           = "opa"
      "openpolicyagent.org/webhook"                    = "ignore"
      "cloud-platform.justice.gov.uk/is-production"    = "true"
      "cloud-platform.justice.gov.uk/environment-name" = "production"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"   = "OPA"
      "cloud-platform.justice.gov.uk/business-unit" = "Platforms"
      "cloud-platform.justice.gov.uk/owner"         = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"   = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
      "cloud-platform.justice.gov.uk/slack-channel" = "cloud-platform"
      "cloud-platform-out-of-hours-alert"           = "true"
    }
  }
}


resource "helm_release" "opa" {
  name       = "opa"
  namespace  = kubernetes_namespace.opa.id
  repository = "https://charts.helm.sh/stable"
  chart      = "opa"
  version    = "1.14.4"

  depends_on = [
    null_resource.kube_system_ns_label,
  ]

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {})]

  lifecycle {
    ignore_changes = [keyring]
  }
}

# By adding this label OPA will ignore kube-system for all policy decisions. 
resource "null_resource" "kube_system_ns_label" {
  provisioner "local-exec" {
    command = "kubectl label --overwrite ns kube-system 'openpolicyagent.org/webhook=ignore'"
  }
}

resource "kubernetes_config_map" "policies_opa" {

  for_each = {
    policy-default                               = "main",
    policy-cloud-platform-admission              = "cloud_platform_admission",
    policy-ingress-clash                         = "ingress_clash",
    policy-service-type                          = "service_type",
    policy-pod-toleration-withkey                = "pod_toleration_withkey",
    policy-pod-toleration-withnullkey            = "pod_toleration_withnullkey",
    policy-ingress-nginx-class-modsec            = "ingress_modsec_nginx_class",
    policy-ingress-no-nginx-class-modsec         = "ingress_modsec_no_nginx_class",
    policy-ingress-nginx-class-modsec-snippet    = "ingress_modsec_snippet_nginx_class",
    policy-ingress-no-nginx-class-modsec-snippet = "ingress_modsec_snippet_no_nginx_class",
    policy-mutate-helpers                        = "mutate_helpers",
    policy-mutate-ingress                        = "mutate_ingress"
  }

  metadata {
    name      = each.key
    namespace = helm_release.opa.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file("${path.module}/resources/policies/${each.value}.rego")
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "valid_host" {
  count = var.enable_invalid_hostname_policy ? 1 : 0
  metadata {
    name      = "valid-host"
    namespace = helm_release.opa.namespace
    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }
  data = {
    main = templatefile("${path.module}/resources/policies-test-cluster/valid_hostname.rego", {
      cluster_domain_name = "*.${var.cluster_domain_name}"
    })
  }
  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

##################
# Resource Quota #
##################

resource "kubernetes_resource_quota" "opa" {
  metadata {
    name      = "namespace-quota"
    namespace = kubernetes_namespace.opa.id
  }
  spec {
    hard = {
      pods = 50
    }
  }
}

##############
# LimitRange #
##############

resource "kubernetes_limit_range" "opa" {
  metadata {
    name      = "limitrange"
    namespace = kubernetes_namespace.opa.id
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "80m"
        memory = "400Mi"
      }
      default_request = {
        cpu    = "4m"
        memory = "50Mi"
      }
    }
  }
}
