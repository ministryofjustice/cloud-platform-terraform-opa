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
    policy-default = "main",
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
