variable "project_name"          { type = string }
variable "region"                { type = string }
variable "vpc_id"                { type = string }
variable "private_subnet_a_id"   { type = string }
variable "private_subnet_b_id"   { type = string }
variable "api_gateway_sg_id"     { type = string }
variable "internal_msa_sg_id"    { type = string }
variable "rds_address"           { type = string }
variable "db_username"           { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "redis_endpoint"        { type = string }
variable "cloudfront_domain"     { type = string }
variable "alb_target_group_arn"  { type = string }
variable "jwt_secret" {
  type      = string
  sensitive = true
}
