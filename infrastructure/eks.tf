###############################################################
# EKS 레이어 (cluster infra - 비용 절감 시 destroy 가능)
# 사용법: terraform apply -target=module.eks -target=module.karpenter ...
###############################################################

###############################################################
# Helm / Kubernetes provider (EKS 클러스터 생성 후 활성화)
###############################################################
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile]
    }
  }
}

###############################################################
# EKS Cluster
###############################################################
module "eks" {
  source = "./modules/eks"

  project_name        = var.project_name
  region              = var.region
  vpc_id              = module.network.vpc_id
  private_subnet_a_id = module.network.private_subnet_a_id
  private_subnet_b_id = module.network.private_subnet_b_id
  public_subnet_a_id  = module.network.public_subnet_a_id
  public_subnet_b_id  = module.network.public_subnet_b_id
}

###############################################################
# Karpenter (노드 오토스케일러)
###############################################################
module "karpenter" {
  source = "./modules/karpenter"

  project_name     = var.project_name
  region           = var.region
  cluster_name     = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url  = module.eks.oidc_issuer_url
  node_role_arn    = module.eks.node_role_arn
}

###############################################################
# IRSA (서비스별 IAM Role for Service Account)
###############################################################
module "irsa" {
  source = "./modules/irsa"

  project_name      = var.project_name
  region            = var.region
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.oidc_issuer_url
}

###############################################################
# AWS Load Balancer Controller
###############################################################
module "alb_controller" {
  source = "./modules/alb-controller"

  project_name      = var.project_name
  region            = var.region
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.oidc_issuer_url
  vpc_id            = module.network.vpc_id

  depends_on = [module.karpenter]
}

###############################################################
# Addons (External Secrets Operator + Argo CD)
###############################################################
module "addons" {
  source = "./modules/addons"

  project_name      = var.project_name
  region            = var.region
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.oidc_issuer_url

  depends_on = [module.karpenter]
}
