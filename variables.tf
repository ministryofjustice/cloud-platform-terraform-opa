variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS annotations and certmanager"
}

variable "enable_invalid_hostname_policy" {
  description = "Enable wheter to have the OPA policy of invalid hostname enabled"
  default     = false
  type        = bool
}
