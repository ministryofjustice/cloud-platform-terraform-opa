package cloud_platform.admission

# This policy deny any ingress that have "kubernetes.io/ingress.class: nginx" annotation(using default ingress-controller) 
# and use 'nginx.ingress.kubernetes.io/enable-modsecurity: "true"' annotation.

deny[msg] {
  input.request.kind.kind == "Ingress"
  input.request.object.metadata.annotations["kubernetes.io/ingress.class"] == "nginx"
  input.request.object.metadata.annotations["nginx.ingress.kubernetes.io/enable-modsecurity"] == "true"
  msg := "No modsec for default ingress class. "
}

deny[msg] {
  input.request.kind.kind == "Ingress"
  input.request.object.spec.ingressClassName == "default"
  input.request.object.metadata.annotations["nginx.ingress.kubernetes.io/enable-modsecurity"] == "true"
  msg := "No modsec for default ingress class. "
}
