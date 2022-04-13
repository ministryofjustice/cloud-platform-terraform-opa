
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

## OPA role was defined in https://github.com/open-policy-agent/kube-mgmt
## but not read from values anymore, to be removed when the chart is fixed

resource "kubernetes_cluster_role" "opa" {
  metadata {
    name = "opa"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["update", "patch", "get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_service_account" "opa" {
  metadata {
    name      = "opa"
    namespace = kubernetes_namespace.opa.name
  }
}

resource "kubernetes_cluster_role_binding" "opa" {
  metadata {
    name = "opa"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.opa.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.opa.name
    namespace = kubernetes_namespace.opa.name
  }
}
