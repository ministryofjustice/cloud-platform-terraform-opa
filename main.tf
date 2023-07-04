
resource "helm_release" "open_policy_agent" {
  name       = "opa"
  namespace  = kubernetes_namespace.opa.id
  repository = "https://open-policy-agent.github.io/kube-mgmt/charts"
  chart      = "opa"
  version    = "3.2.0"

  depends_on = [
    null_resource.kube_system_ns_label,
    kubernetes_service_account.opa
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
    policy-pod-toleration-withkey                = "pod_toleration_withkey",
    policy-pod-toleration-withnullkey            = "pod_toleration_withnullkey",
    policy-ingress-nginx-class-modsec            = "ingress_modsec_nginx_class",
    policy-ingress-no-nginx-class-modsec         = "ingress_modsec_no_nginx_class",
    policy-ingress-no-nginx-class-modsec-snippet = "ingress_modsec_snippet_no_nginx_class",
    policy-ingress-hostname-length               = "ingress_hostname_length",
  }

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.opa.id

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = file("${path.module}/resources/policies/${each.value}.rego")
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubernetes_config_map" "external_dns_policies" {
  for_each = var.enable_external_dns_weight ? {
    external-dns-weight            = "ingress_external_dns_no_weight",
    external-dns-identifier-format = "ingress_external_dns_identifier_format",
  } : {}

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.opa.id

    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = templatefile("${path.module}/resources/policies/external-dns-annotation/${each.value}.rego", {
      cluster_color = var.cluster_color
    })
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

# Policy for test clusters, to use only cluster domain and integration test domain as valid host names

resource "kubernetes_config_map" "valid_host" {
  count = var.enable_invalid_hostname_policy ? 1 : 0

  metadata {
    name      = "valid-host"
    namespace = kubernetes_namespace.opa.id
    labels = {
      "openpolicyagent.org/policy" = "rego"
    }
  }

  data = {
    main = templatefile("${path.module}/resources/policies-test-cluster/valid_hostname.rego", {
      valid_domain_names = "*.${var.cluster_domain_name},*.${var.integration_test_zone}"
    })
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}
