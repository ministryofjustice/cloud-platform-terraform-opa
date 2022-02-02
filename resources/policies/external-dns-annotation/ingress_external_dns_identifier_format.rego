package cloud_platform.admission

# This policy deny any ingress that don't have annotation "external-dns.alpha.kubernetes.io/set-identifier"
# or not use 'cloud-platform.justice.gov.uk/ignore-external-dns-weight: "true"' annotation to ignore about check.

deny[msg] {
  input.request.kind.kind == "Ingress"
  live_1_guide := "https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/migrate-to-live-ingress-annotation.html#add-external-dns-annotations-to-your-ingress-resource-in-live-1"
  live_guide := "https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/migrate-to-live.html#step-5-add-a-new-ingress-resource-in-quot-live-quot-cluster"
  not input.request.object.metadata.annotations["external-dns.alpha.kubernetes.io/set-identifier"] == concat("-", [input.request.object.metadata.name, input.request.object.metadata.namespace, "${cluster_color}"])
  not input.request.object.metadata.annotations["cloud-platform.justice.gov.uk/ignore-external-dns-weight"] == "true"
  msg := sprintf("Please add valid external-dns set-identifier annotation for ingress %v/%v, remember: <ingress-name>-<ns>-<color>. Color is blue for 'live-1' refer: %v and green for 'live' refer: %v", [input.request.object.metadata.namespace, input.request.object.metadata.name, live_1_guide, live_guide])
}
