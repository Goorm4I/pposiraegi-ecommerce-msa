variable "project_name"      { type = string }
variable "region"            { type = string }
variable "cluster_name"      { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_issuer_url"   { type = string }
variable "chart_version"     { type = string; default = "1.8.1" }
variable "vpc_id"            { type = string }
