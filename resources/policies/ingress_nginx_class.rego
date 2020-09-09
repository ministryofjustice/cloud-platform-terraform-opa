package cloud_platform.admission

import data.kubernetes.namespaces

# This policy deny any ingress that don't have "kubernetes.io/ingress.class" annotation
# Excludes above rule if "cloud-platform.justice.gov.uk/ignore-ingress-class" is used in the namespace.

deny[msg] {
  input.request.kind.kind == "Ingress"
  namespace := input.request.object.metadata.namespace
  not namespaces[input.request.namespace].metadata.annotations["cloud-platform.justice.gov.uk/ignore-ingress-class"]
  not input.request.object.metadata.annotations["kubernetes.io/ingress.class"] = namespace
  ingress_name := input.request.object.metadata.name
  msg := sprintf("Please add annotation to ingress (%v)", [namespace])
}
