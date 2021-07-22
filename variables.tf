variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS annotations and certmanager"
}

variable "enable_invalid_hostname_policy" {
  description = "Enable whether to have the OPA policy of invalid hostname enabled"
  default     = false
  type        = bool
}


variable "enable_external_dns_weight" {
  description = "Enable OPA policy to deny ingress creation with out external_dns annotation "
  default     = false
  type        = bool
}
