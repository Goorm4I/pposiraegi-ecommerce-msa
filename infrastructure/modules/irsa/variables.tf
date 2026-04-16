variable "project_name"      { type = string }
variable "region"            { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_issuer_url"   { type = string }
variable "namespace"         { type = string; default = "pposiraegi" }

# 서비스 계정 목록 (key = SA 이름)
variable "service_accounts" {
  type    = set(string)
  default = ["api-gateway", "user-service", "product-service", "order-service"]
}
