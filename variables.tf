variable "cluster_color" {
  description = "Cluster color. This variable is effective only when enable_external_dns_weight is set"
  default     = "green"
  type        = string
}

variable "enable_external_dns_weight" {
  description = "Enable OPA policy to deny ingress creation with out external_dns annotation "
  default     = false
  type        = bool
}
