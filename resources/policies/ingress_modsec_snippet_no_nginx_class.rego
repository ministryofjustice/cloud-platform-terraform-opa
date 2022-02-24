package cloud_platform.admission

# This policy denies any ingress that don't have any ingress class annotation (using default)
# and use "nginx.ingress.kubernetes.io/modsecurity-snippet" annotation.

deny[msg] {
  input.request.kind.kind == "Ingress"
  not input.request.object.metadata.annotations["kubernetes.io/ingress.class"]
  not input.request.object.spec.ingressClassName
  input.request.object.metadata.annotations["nginx.ingress.kubernetes.io/modsecurity-snippet"]
  msg := "No modsec snippet without an ingress class"
}
