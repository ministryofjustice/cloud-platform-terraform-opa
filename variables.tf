
variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS annotations and certmanager"
}

variable "enable_invalid_hostname_policy" {
  description = "Enable wheter to have the OPA policy of invalid hostname enabled"
  default     = false
  type        = bool
}

variable "dependence_deploy" {
  description = "Deploy Module dependence in order to be executed (deploy resource is the helm init)"
}