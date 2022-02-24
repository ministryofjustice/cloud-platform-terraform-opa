package cloud_platform.admission

operations = {"CREATE", "UPDATE"}

forbidden_value := "\\blua_|_lua\\b|_lua_|\\bkubernetes\\.io\\b|root|load_module"

annotations := {
  "nginx.ingress.kubernetes.io/auth-snippet": forbidden_value,
  "nginx.ingress.kubernetes.io/configuration-snippet": forbidden_value,
  "nginx.ingress.kubernetes.io/server-snippet": forbidden_value,
  "nginx.ingress.kubernetes.io/modsecurity-snippet": forbidden_value,
}

deny[msg] {
  input.request.kind.kind == "Ingress"
  operations[input.request.operation]

  some key; regex.match(annotations[key], input.request.object.metadata.annotations[key])
  msg := sprintf("Ingress '%v/%v' contains unsafe directive(s) in '%v' annotation", [input.request.object.metadata.namespace, input.request.object.metadata.name, key])
}
