###############################################################
# Provider
###############################################################
provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.aws_profile
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

###############################################################
# Shared random suffix (frontend S3 + pipeline artifacts S3)
###############################################################
resource "random_id" "suffix" {
  byte_length = 4
}

###############################################################
# Modules
###############################################################
module "network" {
  source = "./modules/network"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_a_cidr  = var.public_subnet_a_cidr
  public_subnet_b_cidr  = var.public_subnet_b_cidr
  private_subnet_a_cidr = var.private_subnet_a_cidr
  private_subnet_b_cidr = var.private_subnet_b_cidr
}

module "database" {
  source = "./modules/database"

  project_name        = var.project_name
  private_subnet_a_id = module.network.private_subnet_a_id
  private_subnet_b_id = module.network.private_subnet_b_id
  rds_sg_id           = module.network.rds_sg_id
  db_username         = var.db_username
  db_password         = var.db_password
}

module "cache" {
  source = "./modules/cache"

  project_name        = var.project_name
  private_subnet_a_id = module.network.private_subnet_a_id
  private_subnet_b_id = module.network.private_subnet_b_id
  redis_sg_id         = module.network.redis_sg_id
}

module "cdn" {
  source = "./modules/cdn"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  project_name        = var.project_name
  domain_name         = var.domain_name
  vpc_id              = module.network.vpc_id
  public_subnet_a_id  = module.network.public_subnet_a_id
  public_subnet_b_id  = module.network.public_subnet_b_id
  alb_sg_id           = module.network.alb_sg_id
  suffix              = random_id.suffix.hex
}

module "ecs" {
  source = "./modules/ecs"

  project_name         = var.project_name
  region               = var.region
  vpc_id               = module.network.vpc_id
  private_subnet_a_id  = module.network.private_subnet_a_id
  private_subnet_b_id  = module.network.private_subnet_b_id
  api_gateway_sg_id    = module.network.api_gateway_sg_id
  internal_msa_sg_id   = module.network.internal_msa_sg_id
  rds_address          = module.database.address
  db_username          = var.db_username
  db_password          = var.db_password
  redis_endpoint       = module.cache.redis_endpoint
  cloudfront_domain    = module.cdn.cloudfront_domain
  alb_target_group_arn = module.cdn.alb_target_group_arn
  jwt_secret           = var.jwt_secret
}

module "pipeline" {
  source = "./modules/pipeline"

  project_name              = var.project_name
  region                    = var.region
  suffix                    = random_id.suffix.hex
  frontend_s3_bucket_arn    = module.cdn.s3_bucket_arn
  frontend_s3_bucket_name   = module.cdn.s3_bucket_name
  ecr_repository_urls       = module.ecs.ecr_repository_urls
  ecs_cluster_name          = module.ecs.cluster_name
  ecs_service_names         = module.ecs.ecs_service_names
  cloudfront_distribution_id = module.cdn.cloudfront_id
  github_repo               = var.github_repo
  github_branch             = var.github_branch
  codestar_connection_arn   = var.codestar_connection_arn
}

module "monitoring" {
  source = "./modules/monitoring"

  project_name   = var.project_name
  region         = var.region
  alb_arn_suffix = module.cdn.alb_arn_suffix
}
