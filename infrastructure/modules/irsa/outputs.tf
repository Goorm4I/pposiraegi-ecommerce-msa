output "role_arns" {
  description = "서비스별 IRSA role ARN map (key = SA 이름)"
  value       = { for k, r in aws_iam_role.service : k => r.arn }
}
