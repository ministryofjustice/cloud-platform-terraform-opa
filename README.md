# cloud-platform-terraform-opa

Terraform module that deploys cloud-platform's open policy agent. It includes all required policies and kubernetes resources in order to get up and running open policy agent in any eks cluster

## Usage

```hcl
module "opa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opa?ref=0.0.1"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.open_policy_agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map.external_dns_policies](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.policies_opa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.valid_host](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_limit_range.opa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range) | resource |
| [kubernetes_namespace.opa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_resource_quota.namespace_quota](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota) | resource |
| [null_resource.kube_system_ns_label](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_color"></a> [cluster\_color](#input\_cluster\_color) | Cluster color (blue/green). This variable is effective only when enable\_external\_dns\_weight is set | `string` | `"blue"` | no |
| <a name="input_cluster_domain_name"></a> [cluster\_domain\_name](#input\_cluster\_domain\_name) | The cluster domain used for externalDNS annotations and certmanager | `any` | n/a | yes |
| <a name="input_enable_external_dns_weight"></a> [enable\_external\_dns\_weight](#input\_enable\_external\_dns\_weight) | Enable OPA policy to deny ingress creation with out external\_dns annotation | `bool` | `false` | no |
| <a name="input_enable_invalid_hostname_policy"></a> [enable\_invalid\_hostname\_policy](#input\_enable\_invalid\_hostname\_policy) | Enable whether to have the OPA policy of invalid hostname enabled | `bool` | `false` | no |
| <a name="input_integration_test_zone"></a> [integration\_test\_zone](#input\_integration\_test\_zone) | Integration test zone, for test clusters to use it for valid ingress policy | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_opa_status"></a> [helm\_opa\_status](#output\_helm\_opa\_status) | n/a |
<!-- END_TF_DOCS -->
