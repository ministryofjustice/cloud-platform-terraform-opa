package cloud_platform.admission

# This policy deny any ingress that don't have annotation "external-dns.alpha.kubernetes.io/set-identifier"
# or not use 'cloud-platform.justice.gov.uk/ignore-external-dns-weight: "true"' annotation to ignore about check.

deny[msg] {
  input.request.kind.kind == "Ingress"
  not input.request.object.metadata.annotations["external-dns.alpha.kubernetes.io/set-identifier"] == concat("-", [input.request.object.metadata.name, input.request.object.metadata.namespace, ${cluster_color}])
  not input.request.object.metadata.annotations["cloud-platform.justice.gov.uk/ignore-external-dns-weight"] == "true"
  msg := "Please add valid external-dns identifier for ingress, remember: <ingress-name>-<ns>-<color>. Color is either blue or green"
}
