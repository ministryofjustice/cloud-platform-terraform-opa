
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
      "cloud-platform.justice.gov.uk/business-unit" = "cloud-platform"
      "cloud-platform.justice.gov.uk/owner"         = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"   = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
      "cloud-platform.justice.gov.uk/slack-channel" = "cloud-platform"
    }
  }
}

resource "helm_release" "open_policy_agent" {
  name       = "opa"
  namespace  = kubernetes_namespace.opa.id
  repository = "stable"
  chart      = "opa"
  version    = "1.13.4"

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

resource "kubernetes_config_map" "policy_default" {
  metadata {
    name      = "policy-default"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file("${path.module}/resources/policies/main.rego")
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "valid_host" {
  count = var.enable_invalid_hostname_policy ? 1 : 0
  metadata {
    name      = "valid-host"
    namespace = helm_release.open_policy_agent.namespace
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

resource "kubernetes_config_map" "policy_cloud_platform_admission" {
  metadata {
    name      = "policy-cloud-platform-admission"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file(
      "${path.module}/resources/policies/cloud_platform_admission.rego",
    )
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "policy_ingress_clash" {
  metadata {
    name      = "policy-ingress-clash"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file("${path.module}/resources/policies/ingress_clash.rego")
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "policy_service_type" {
  metadata {
    name      = "policy-service-type"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file("${path.module}/resources/policies/service_type.rego")
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "policy_pod_toleration_withkey" {
  metadata {
    name      = "policy-pod-toleration-withkey"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file(
      "${path.module}/resources/policies/pod_toleration_withkey.rego",
    )
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "policy_pod_toleration_withnullkey" {
  metadata {
    name      = "policy-pod-toleration-withnullkey"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file(
      "${path.module}/resources/policies/pod_toleration_withnullkey.rego",
    )
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "policy_ingress_nginx_class_modsec" {
  metadata {
    name      = "policy-ingress-nginx-class-modsec"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file(
      "${path.module}/resources/policies/ingress_modsec_nginx_class.rego",
    )
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "policy_ingress_no_nginx_class_modsec" {
  metadata {
    name      = "policy-ingress-no-nginx-class-modsec"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file(
      "${path.module}/resources/policies/ingress_modsec_no_nginx_class.rego",
    )
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "policy_ingress_nginx_class_modsec_snippet" {
  metadata {
    name      = "policy-ingress-nginx-class-modsec-snippet"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file(
      "${path.module}/resources/policies/ingress_modsec_snippet_nginx_class.rego",
    )
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

resource "kubernetes_config_map" "policy_ingress_no_nginx_class_modsec_snippet" {
  metadata {
    name      = "policy-ingress-no-nginx-class-modsec-snippet"
    namespace = helm_release.open_policy_agent.namespace

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file(
      "${path.module}/resources/policies/ingress_modsec_snippet_no_nginx_class.rego",
    )
  }

  lifecycle {
    ignore_changes = [metadata.0.annotations]
  }
}

##################
# Resource Quota #
##################

resource "kubernetes_resource_quota" "namespace_quota" {
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
