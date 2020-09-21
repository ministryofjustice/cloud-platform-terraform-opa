
resource "kubernetes_namespace" "opa" {
  metadata {
    name = "opa"

    labels = {
      "name"                        = "opa"
      "openpolicyagent.org/webhook" = "ignore"
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

