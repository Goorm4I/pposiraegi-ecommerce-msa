output "artifacts_bucket_arn"  { value = aws_s3_bucket.pipeline_artifacts.arn }
output "artifacts_bucket_name" { value = aws_s3_bucket.pipeline_artifacts.bucket }
