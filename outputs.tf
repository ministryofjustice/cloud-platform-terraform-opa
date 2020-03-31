
output "helm_opa_status" {
  value = helm_release.open_policy_agent.status
}
