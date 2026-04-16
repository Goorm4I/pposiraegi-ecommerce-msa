variable "project_name"     { type = string }
variable "region"           { type = string }
variable "cluster_name"     { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_issuer_url"  { type = string }
variable "node_role_arn"    { type = string }

variable "karpenter_version" {
  type    = string
  default = "1.1.1"
}
