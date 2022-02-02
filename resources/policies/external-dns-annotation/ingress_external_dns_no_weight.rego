package cloud_platform.admission

# This policy deny any ingress that don't have annotation "external-dns.alpha.kubernetes.io/aws-weight"
# or not use 'cloud-platform.justice.gov.uk/ignore-external-dns-weight: "true"' annotation to ignore about check.

deny[msg] {
  input.request.kind.kind == "Ingress"
  live_1_guide := "https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/migrate-to-live-ingress-annotation.html#add-external-dns-annotations-to-your-ingress-resource-in-live-1"
  live_guide := "https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/migrate-to-live.html#step-5-add-a-new-ingress-resource-in-quot-live-quot-cluster"
  not input.request.object.metadata.annotations["external-dns.alpha.kubernetes.io/aws-weight"]
  not input.request.object.metadata.annotations["cloud-platform.justice.gov.uk/ignore-external-dns-weight"] == "true"
  msg := sprintf("\nPlease add valid external-dns set-identifier annotation for ingress %v/%v, remember: <ingress-name>-<ns>-<color>. \nThe color 'blue' corresponds to the 'live-1' ingress, for reference: \n%v. \nThe color 'green' corresponds to the 'live' ingress, for reference: \n%v", [input.request.object.metadata.namespace, input.request.object.metadata.name, live_1_guide, live_guide])
}
