output "cloudfront_url" {
  description = "프론트엔드 접속 URL (CloudFront)"
  value       = "https://${module.cdn.cloudfront_domain}"
}

output "cloudfront_id" {
  description = "CloudFront Distribution ID (캐시 무효화용)"
  value       = module.cdn.cloudfront_id
}

output "alb_dns" {
  description = "백엔드 ALB DNS (API 직접 접근용)"
  value       = "http://${module.cdn.alb_dns_name}"
}

output "s3_bucket_name" {
  description = "프론트엔드 S3 버킷명 (빌드 파일 업로드용)"
  value       = module.cdn.s3_bucket_name
}

output "ecr_repository_urls" {
  description = "백엔드 MSA ECR 레포지토리 URL 목록"
  value       = module.ecs.ecr_repository_urls
}

output "frontend_deploy_command" {
  description = "프론트엔드 S3 배포 명령어"
  value       = "aws s3 sync ./build s3://${module.cdn.s3_bucket_name} --profile goorm --delete"
}

output "backend_push_command" {
  description = "백엔드 ECR 푸시 예시 명령어 (api-gateway 예시)"
  value       = "docker tag api-gateway:latest ${module.ecs.ecr_repository_urls["api-gateway"]}:latest && docker push ${module.ecs.ecr_repository_urls["api-gateway"]}:latest"
}

output "elasticache_endpoint" {
  description = "ElastiCache Redis 엔드포인트"
  value       = module.cache.redis_endpoint
}

output "rds_endpoint" {
  description = "RDS PostgreSQL 엔드포인트"
  value       = module.database.address
}

output "rds_port" {
  description = "RDS PostgreSQL 포트"
  value       = module.database.port
}

output "sns_topic_arn" {
  description = "SNS 알림 토픽 ARN (알림 구독용)"
  value       = module.monitoring.sns_topic_arn
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch 대시보드 URL"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${module.monitoring.dashboard_name}"
}

output "ecs_cluster_name" {
  description = "ECS 클러스터 이름 (모니터링용)"
  value       = module.ecs.cluster_name
}

output "alb_arn_suffix" {
  description = "ALB ARN Suffix (CloudWatch 알람용)"
  value       = module.cdn.alb_arn_suffix
}
