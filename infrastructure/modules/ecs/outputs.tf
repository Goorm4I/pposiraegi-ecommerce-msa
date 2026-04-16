output "cluster_name"         { value = aws_ecs_cluster.main.name }
output "cluster_id"           { value = aws_ecs_cluster.main.id }
output "ecr_repository_urls"  { value = { for k, v in aws_ecr_repository.msa : k => v.repository_url } }
output "ecs_service_names"    { value = { for k, v in aws_ecs_service.msa : k => v.name } }
output "ssm_db_password_arn"  { value = aws_ssm_parameter.db_password.arn }
output "ssm_jwt_secret_arn"   { value = aws_ssm_parameter.jwt_secret.arn }
