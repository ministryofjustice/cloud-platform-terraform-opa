variable "cluster_domain_name" {
  description = "The cluster domain used for externalDNS annotations and certmanager"
}

variable "enable_invalid_hostname_policy" {
  description = "Enable whether to have the OPA policy of invalid hostname enabled"
  default     = false
  type        = bool
}

variable "cluster_color" {
  description = "Cluster color (blue/green). This variable is effective only when enable_external_dns_weight is set"
  default     = "blue"
  type        = string
}

variable "enable_external_dns_weight" {
  description = "Enable OPA policy to deny ingress creation with out external_dns annotation "
  default     = false
  type        = bool
}

variable "integration_test_zone" {
  description = "Integration test zone, for test clusters to use it for valid ingress policy"
  default     = ""
}