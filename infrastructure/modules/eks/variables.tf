variable "project_name"        { type = string }
variable "region"              { type = string }
variable "vpc_id"              { type = string }
variable "private_subnet_a_id" { type = string }
variable "private_subnet_b_id" { type = string }
variable "public_subnet_a_id"  { type = string }
variable "public_subnet_b_id"  { type = string }

variable "cluster_version" {
  type    = string
  default = "1.31"
}

# Karpenter용 시스템 노드그룹 설정 (워커 노드는 Karpenter가 관리)
variable "system_node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "system_node_min"     { type = number; default = 1 }
variable "system_node_max"     { type = number; default = 3 }
variable "system_node_desired" { type = number; default = 2 }
