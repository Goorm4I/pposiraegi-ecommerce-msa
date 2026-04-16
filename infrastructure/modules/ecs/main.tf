locals {
  services = toset(["api-gateway", "user-service", "product-service", "order-service"])
}

###############################################################
# SSM Parameter Store
###############################################################
resource "aws_ssm_parameter" "jwt_secret" {
  name  = "/${var.project_name}/jwt_secret"
  type  = "SecureString"
  value = var.jwt_secret
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/db_password"
  type  = "SecureString"
  value = var.db_password
}

###############################################################
# ECR Repositories
###############################################################
resource "aws_ecr_repository" "msa" {
  for_each             = local.services
  name                 = "${var.project_name}-${each.key}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

###############################################################
# CloudWatch Log Groups
###############################################################
resource "aws_cloudwatch_log_group" "msa" {
  for_each          = local.services
  name              = "/ecs/${var.project_name}-${each.key}"
  retention_in_days = 7
}

###############################################################
# ECS Cluster
###############################################################
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

###############################################################
# IAM Roles
###############################################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_ssm_policy" {
  name = "${var.project_name}-ecs-ssm-policy"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["ssm:GetParameters"]
      Resource = [
        aws_ssm_parameter.jwt_secret.arn,
        aws_ssm_parameter.db_password.arn
      ]
    }]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

###############################################################
# Cloud Map (Service Discovery)
###############################################################
resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "pposiraegi.internal"
  description = "Private DNS namespace for microservices"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "msa" {
  for_each = local.services

  name = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

###############################################################
# ECS Task Definitions
###############################################################
resource "aws_ecs_task_definition" "msa" {
  for_each                 = local.services
  family                   = "${var.project_name}-${each.key}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = each.key
    image     = "${aws_ecr_repository.msa[each.key].repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
    }]
    environment = [
      { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
      { name = "DB_HOST", value = var.rds_address },
      { name = "DB_USERNAME", value = var.db_username },
      { name = "REDIS_HOST", value = var.redis_endpoint },
      { name = "CORS_ALLOWED_ORIGINS", value = "https://${var.cloudfront_domain}" },
      { name = "USER_SERVICE_URL", value = "http://user-service.pposiraegi.internal:8080" },
      { name = "PRODUCT_SERVICE_URL", value = "http://product-service.pposiraegi.internal:8080" },
      { name = "ORDER_SERVICE_URL", value = "http://order-service.pposiraegi.internal:8080" },
      { name = "USER_GRPC_URL", value = "static://user-service.pposiraegi.internal:9090" },
      { name = "PRODUCT_GRPC_URL", value = "static://product-service.pposiraegi.internal:9090" }
    ]
    secrets = [
      { name = "DB_PASSWORD", valueFrom = aws_ssm_parameter.db_password.arn },
      { name = "JWT_SECRET", valueFrom = aws_ssm_parameter.jwt_secret.arn }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.msa[each.key].name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

###############################################################
# ECS Services
###############################################################
resource "aws_ecs_service" "msa" {
  for_each        = local.services
  name            = "${var.project_name}-${each.key}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.msa[each.key].arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [var.private_subnet_a_id, var.private_subnet_b_id]
    security_groups = each.key == "api-gateway" ? [var.api_gateway_sg_id] : [var.internal_msa_sg_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.msa[each.key].arn
  }

  dynamic "load_balancer" {
    for_each = each.key == "api-gateway" ? [1] : []
    content {
      target_group_arn = var.alb_target_group_arn
      container_name   = each.key
      container_port   = 8080
    }
  }

}
