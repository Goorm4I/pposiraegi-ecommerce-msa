variable "project_name"      { type = string }
variable "private_subnet_a_id" { type = string }
variable "private_subnet_b_id" { type = string }
variable "rds_sg_id"           { type = string }
variable "db_username"         { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
