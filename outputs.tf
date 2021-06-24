
output "helm_opa_status" {
  value = helm_release.opa_validate.status
}
