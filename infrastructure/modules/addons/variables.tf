variable "project_name"      { type = string }
variable "region"            { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_issuer_url"   { type = string }

variable "eso_chart_version"   { type = string; default = "0.9.18" }
variable "argocd_chart_version" { type = string; default = "7.3.11" }

# Argo CD: GitOps 레포 URL (App of Apps 루트)
variable "gitops_repo_url" {
  type    = string
  default = ""
}

# Argo CD admin 초기 비밀번호 (bcrypt hash)
# htpasswd -nbBC 10 "" <password> | tr -d ':\n' | sed 's/$2y/$2a/'
variable "argocd_admin_password_hash" {
  type      = string
  sensitive = true
  default   = ""   # 배포 후 argocd admin password set으로 변경 권장
}
