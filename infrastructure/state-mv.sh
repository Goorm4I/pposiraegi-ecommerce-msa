#!/usr/bin/env bash
# terraform state mv 스크립트
# 실행: cd infrastructure && AWS_PROFILE=goorm bash state-mv.sh
set -e

echo "=== network module ==="
terraform state mv aws_vpc.main                              module.network.aws_vpc.main
terraform state mv aws_internet_gateway.igw                  module.network.aws_internet_gateway.igw
terraform state mv aws_subnet.public_a                       module.network.aws_subnet.public_a
terraform state mv aws_subnet.public_b                       module.network.aws_subnet.public_b
terraform state mv aws_subnet.private_a                      module.network.aws_subnet.private_a
terraform state mv aws_subnet.private_b                      module.network.aws_subnet.private_b
terraform state mv aws_route_table.public_rt                 module.network.aws_route_table.public_rt
terraform state mv aws_route_table.private_rt                module.network.aws_route_table.private_rt
terraform state mv aws_route_table_association.public_a      module.network.aws_route_table_association.public_a
terraform state mv aws_route_table_association.public_b      module.network.aws_route_table_association.public_b
terraform state mv aws_route_table_association.private_a     module.network.aws_route_table_association.private_a
terraform state mv aws_route_table_association.private_b     module.network.aws_route_table_association.private_b
terraform state mv aws_eip.nat                               module.network.aws_eip.nat
terraform state mv aws_nat_gateway.nat                       module.network.aws_nat_gateway.nat
terraform state mv aws_security_group.alb_sg                 module.network.aws_security_group.alb_sg
terraform state mv aws_security_group.api_gateway_sg         module.network.aws_security_group.api_gateway_sg
terraform state mv aws_security_group.internal_msa_sg        module.network.aws_security_group.internal_msa_sg
terraform state mv aws_security_group.rds_sg                 module.network.aws_security_group.rds_sg
terraform state mv aws_security_group.redis_sg               module.network.aws_security_group.redis_sg

echo "=== database module ==="
terraform state mv aws_db_subnet_group.rds                   module.database.aws_db_subnet_group.rds
terraform state mv aws_db_instance.postgres                  module.database.aws_db_instance.postgres

echo "=== cache module ==="
terraform state mv aws_elasticache_subnet_group.redis        module.cache.aws_elasticache_subnet_group.redis
terraform state mv aws_elasticache_cluster.redis             module.cache.aws_elasticache_cluster.redis

echo "=== cdn module ==="
terraform state mv aws_s3_bucket.frontend                    module.cdn.aws_s3_bucket.frontend
terraform state mv aws_s3_bucket_public_access_block.frontend  module.cdn.aws_s3_bucket_public_access_block.frontend
terraform state mv aws_s3_bucket_website_configuration.frontend module.cdn.aws_s3_bucket_website_configuration.frontend
terraform state mv aws_cloudfront_origin_access_control.frontend_oac module.cdn.aws_cloudfront_origin_access_control.frontend_oac
terraform state mv aws_lb.alb                                module.cdn.aws_lb.alb
terraform state mv aws_lb_target_group.backend_tg            module.cdn.aws_lb_target_group.backend_tg
terraform state mv aws_lb_listener.http                      module.cdn.aws_lb_listener.http
terraform state mv aws_cloudfront_distribution.frontend      module.cdn.aws_cloudfront_distribution.frontend
terraform state mv aws_s3_bucket_policy.frontend             module.cdn.aws_s3_bucket_policy.frontend
terraform state mv aws_acm_certificate.cert                  module.cdn.aws_acm_certificate.cert
terraform state mv 'aws_route53_record.cert_validation["*.pposiraegi.cloud"]' 'module.cdn.aws_route53_record.cert_validation["*.pposiraegi.cloud"]'
terraform state mv 'aws_route53_record.cert_validation["pposiraegi.cloud"]'   'module.cdn.aws_route53_record.cert_validation["pposiraegi.cloud"]'
terraform state mv aws_acm_certificate_validation.cert       module.cdn.aws_acm_certificate_validation.cert
terraform state mv aws_route53_record.root                   module.cdn.aws_route53_record.root
terraform state mv aws_route53_record.www                    module.cdn.aws_route53_record.www

echo "=== ecs module ==="
terraform state mv aws_ssm_parameter.jwt_secret              module.ecs.aws_ssm_parameter.jwt_secret
terraform state mv aws_ssm_parameter.db_password             module.ecs.aws_ssm_parameter.db_password
terraform state mv 'aws_ecr_repository.msa["api-gateway"]'      'module.ecs.aws_ecr_repository.msa["api-gateway"]'
terraform state mv 'aws_ecr_repository.msa["order-service"]'     'module.ecs.aws_ecr_repository.msa["order-service"]'
terraform state mv 'aws_ecr_repository.msa["product-service"]'   'module.ecs.aws_ecr_repository.msa["product-service"]'
terraform state mv 'aws_ecr_repository.msa["user-service"]'      'module.ecs.aws_ecr_repository.msa["user-service"]'
terraform state mv 'aws_cloudwatch_log_group.msa["api-gateway"]' 'module.ecs.aws_cloudwatch_log_group.msa["api-gateway"]'
terraform state mv 'aws_cloudwatch_log_group.msa["order-service"]' 'module.ecs.aws_cloudwatch_log_group.msa["order-service"]'
terraform state mv 'aws_cloudwatch_log_group.msa["product-service"]' 'module.ecs.aws_cloudwatch_log_group.msa["product-service"]'
terraform state mv 'aws_cloudwatch_log_group.msa["user-service"]' 'module.ecs.aws_cloudwatch_log_group.msa["user-service"]'
terraform state mv aws_ecs_cluster.main                      module.ecs.aws_ecs_cluster.main
terraform state mv aws_iam_role.ecs_task_execution_role      module.ecs.aws_iam_role.ecs_task_execution_role
terraform state mv aws_iam_role_policy_attachment.ecs_task_execution_role_policy module.ecs.aws_iam_role_policy_attachment.ecs_task_execution_role_policy
terraform state mv aws_iam_role_policy.ecs_task_execution_ssm_policy module.ecs.aws_iam_role_policy.ecs_task_execution_ssm_policy
terraform state mv aws_iam_role.ecs_task_role                module.ecs.aws_iam_role.ecs_task_role
terraform state mv aws_service_discovery_private_dns_namespace.internal module.ecs.aws_service_discovery_private_dns_namespace.internal
terraform state mv 'aws_service_discovery_service.msa["api-gateway"]'    'module.ecs.aws_service_discovery_service.msa["api-gateway"]'
terraform state mv 'aws_service_discovery_service.msa["order-service"]'   'module.ecs.aws_service_discovery_service.msa["order-service"]'
terraform state mv 'aws_service_discovery_service.msa["product-service"]' 'module.ecs.aws_service_discovery_service.msa["product-service"]'
terraform state mv 'aws_service_discovery_service.msa["user-service"]'    'module.ecs.aws_service_discovery_service.msa["user-service"]'
terraform state mv 'aws_ecs_task_definition.msa["api-gateway"]'     'module.ecs.aws_ecs_task_definition.msa["api-gateway"]'
terraform state mv 'aws_ecs_task_definition.msa["order-service"]'    'module.ecs.aws_ecs_task_definition.msa["order-service"]'
terraform state mv 'aws_ecs_task_definition.msa["product-service"]'  'module.ecs.aws_ecs_task_definition.msa["product-service"]'
terraform state mv 'aws_ecs_task_definition.msa["user-service"]'     'module.ecs.aws_ecs_task_definition.msa["user-service"]'
terraform state mv 'aws_ecs_service.msa["api-gateway"]'     'module.ecs.aws_ecs_service.msa["api-gateway"]'
terraform state mv 'aws_ecs_service.msa["order-service"]'    'module.ecs.aws_ecs_service.msa["order-service"]'
terraform state mv 'aws_ecs_service.msa["product-service"]'  'module.ecs.aws_ecs_service.msa["product-service"]'
terraform state mv 'aws_ecs_service.msa["user-service"]'     'module.ecs.aws_ecs_service.msa["user-service"]'

echo "=== pipeline module ==="
terraform state mv aws_s3_bucket.pipeline_artifacts          module.pipeline.aws_s3_bucket.pipeline_artifacts
terraform state mv aws_iam_role.codebuild_role               module.pipeline.aws_iam_role.codebuild_role
terraform state mv aws_iam_role_policy.codebuild_policy      module.pipeline.aws_iam_role_policy.codebuild_policy
terraform state mv aws_iam_role.codepipeline_role            module.pipeline.aws_iam_role.codepipeline_role
terraform state mv aws_iam_role_policy.codepipeline_policy   module.pipeline.aws_iam_role_policy.codepipeline_policy
terraform state mv 'aws_codebuild_project.backend["api-gateway"]'    'module.pipeline.aws_codebuild_project.backend["api-gateway"]'
terraform state mv 'aws_codebuild_project.backend["order-service"]'   'module.pipeline.aws_codebuild_project.backend["order-service"]'
terraform state mv 'aws_codebuild_project.backend["product-service"]' 'module.pipeline.aws_codebuild_project.backend["product-service"]'
terraform state mv 'aws_codebuild_project.backend["user-service"]'    'module.pipeline.aws_codebuild_project.backend["user-service"]'
terraform state mv aws_codebuild_project.frontend            module.pipeline.aws_codebuild_project.frontend
terraform state mv 'aws_codepipeline.backend["api-gateway"]'    'module.pipeline.aws_codepipeline.backend["api-gateway"]'
terraform state mv 'aws_codepipeline.backend["order-service"]'   'module.pipeline.aws_codepipeline.backend["order-service"]'
terraform state mv 'aws_codepipeline.backend["product-service"]' 'module.pipeline.aws_codepipeline.backend["product-service"]'
terraform state mv 'aws_codepipeline.backend["user-service"]'    'module.pipeline.aws_codepipeline.backend["user-service"]'
terraform state mv aws_codepipeline.frontend                 module.pipeline.aws_codepipeline.frontend

echo "=== monitoring module ==="
terraform state mv aws_sns_topic.alerts                              module.monitoring.aws_sns_topic.alerts
terraform state mv aws_cloudwatch_metric_alarm.high_cpu_api_gateway  module.monitoring.aws_cloudwatch_metric_alarm.high_cpu_api_gateway
terraform state mv aws_cloudwatch_metric_alarm.high_cpu_user_service module.monitoring.aws_cloudwatch_metric_alarm.high_cpu_user_service
terraform state mv aws_cloudwatch_metric_alarm.high_cpu_product_service module.monitoring.aws_cloudwatch_metric_alarm.high_cpu_product_service
terraform state mv aws_cloudwatch_metric_alarm.high_cpu_order_service module.monitoring.aws_cloudwatch_metric_alarm.high_cpu_order_service
terraform state mv aws_cloudwatch_metric_alarm.high_memory_api_gateway module.monitoring.aws_cloudwatch_metric_alarm.high_memory_api_gateway
terraform state mv aws_cloudwatch_metric_alarm.high_memory_user_service module.monitoring.aws_cloudwatch_metric_alarm.high_memory_user_service
terraform state mv aws_cloudwatch_metric_alarm.high_memory_product_service module.monitoring.aws_cloudwatch_metric_alarm.high_memory_product_service
terraform state mv aws_cloudwatch_metric_alarm.high_memory_order_service module.monitoring.aws_cloudwatch_metric_alarm.high_memory_order_service
terraform state mv aws_cloudwatch_metric_alarm.alb_high_response_time module.monitoring.aws_cloudwatch_metric_alarm.alb_high_response_time
terraform state mv aws_cloudwatch_metric_alarm.alb_high_5xx           module.monitoring.aws_cloudwatch_metric_alarm.alb_high_5xx
terraform state mv aws_cloudwatch_metric_alarm.no_running_tasks_api_gateway module.monitoring.aws_cloudwatch_metric_alarm.no_running_tasks_api_gateway
terraform state mv aws_cloudwatch_metric_alarm.no_running_tasks_user_service module.monitoring.aws_cloudwatch_metric_alarm.no_running_tasks_user_service
terraform state mv aws_cloudwatch_metric_alarm.no_running_tasks_product_service module.monitoring.aws_cloudwatch_metric_alarm.no_running_tasks_product_service
terraform state mv aws_cloudwatch_metric_alarm.no_running_tasks_order_service module.monitoring.aws_cloudwatch_metric_alarm.no_running_tasks_order_service
terraform state mv aws_cloudwatch_dashboard.production_health         module.monitoring.aws_cloudwatch_dashboard.production_health

echo ""
echo "=== state mv 완료. terraform init && terraform plan 실행 중 ==="
