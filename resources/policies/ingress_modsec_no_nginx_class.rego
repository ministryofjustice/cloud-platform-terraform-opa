package cloud_platform.admission

# This policy deny any ingress that don't have "kubernetes.io/ingress.class" annotation(using default ingress-controller) 
# and use 'nginx.ingress.kubernetes.io/enable-modsecurity: "true"' annotation.

deny[msg] {
  input.request.kind.kind == "Ingress"
  not input.request.object.metadata.annotations["kubernetes.io/ingress.class"]
  not input.request.object.spec.ingressClassName
  input.request.object.metadata.annotations["nginx.ingress.kubernetes.io/enable-modsecurity"] == "true"
  msg := "No modsec without an ingress class. "
}
