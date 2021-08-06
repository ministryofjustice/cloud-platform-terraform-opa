package cloud_platform.admission

# This policy deny any ingress that don't have annotation "external-dns.alpha.kubernetes.io/set-identifier"
# or not use 'cloud-platform.justice.gov.uk/ignore-external-dns-weight: "true"' annotation to ignore about check.

deny[msg] {
  input.request.kind.kind == "Ingress"
  not input.request.object.metadata.annotations["external-dns.alpha.kubernetes.io/set-identifier"]
  not input.request.object.metadata.annotations["cloud-platform.justice.gov.uk/ignore-external-dns-weight"] == "true"
  msg := "Please add external-dns annotation for ingress"
}
