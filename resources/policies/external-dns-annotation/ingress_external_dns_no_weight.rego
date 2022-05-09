package cloud_platform.admission

# This policy deny any ingress that don't have annotation "external-dns.alpha.kubernetes.io/aws-weight"
# or not use 'cloud-platform.justice.gov.uk/ignore-external-dns-weight: "true"' annotation to ignore about check.

deny[msg] {
  input.request.kind.kind == "Ingress"
  not input.request.object.metadata.annotations["external-dns.alpha.kubernetes.io/aws-weight"]
  not input.request.object.metadata.annotations["cloud-platform.justice.gov.uk/ignore-external-dns-weight"] == "true"
  msg := sprintf("\nPlease add valid external-dns set-identifier annotation for ingress %v/%v, remember: <ingress-name>-<ns>-${cluster_color}", [input.request.object.metadata.namespace, input.request.object.metadata.name])
}
