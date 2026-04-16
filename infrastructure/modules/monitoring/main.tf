###############################################################
# SNS
###############################################################
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
  tags = { Name = "${var.project_name}-alerts" }
}

###############################################################
# CloudWatch Alarms - CPU
###############################################################
resource "aws_cloudwatch_metric_alarm" "high_cpu_api_gateway" {
  alarm_name          = "${var.project_name}-api-gateway-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "API Gateway CPU utilization is too high"
  dimensions          = { ServiceName = "${var.project_name}-api-gateway-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_user_service" {
  alarm_name          = "${var.project_name}-user-service-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "User Service CPU utilization is too high"
  dimensions          = { ServiceName = "${var.project_name}-user-service-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_product_service" {
  alarm_name          = "${var.project_name}-product-service-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Product Service CPU utilization is too high"
  dimensions          = { ServiceName = "${var.project_name}-product-service-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_order_service" {
  alarm_name          = "${var.project_name}-order-service-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Order Service CPU utilization is too high"
  dimensions          = { ServiceName = "${var.project_name}-order-service-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

###############################################################
# CloudWatch Alarms - Memory
###############################################################
resource "aws_cloudwatch_metric_alarm" "high_memory_api_gateway" {
  alarm_name          = "${var.project_name}-api-gateway-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "API Gateway Memory utilization is too high"
  dimensions          = { ServiceName = "${var.project_name}-api-gateway-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_memory_user_service" {
  alarm_name          = "${var.project_name}-user-service-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "User Service Memory utilization is too high"
  dimensions          = { ServiceName = "${var.project_name}-user-service-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_memory_product_service" {
  alarm_name          = "${var.project_name}-product-service-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "Product Service Memory utilization is too high"
  dimensions          = { ServiceName = "${var.project_name}-product-service-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_memory_order_service" {
  alarm_name          = "${var.project_name}-order-service-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "Order Service Memory utilization is too high"
  dimensions          = { ServiceName = "${var.project_name}-order-service-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

###############################################################
# CloudWatch Alarms - ALB
###############################################################
resource "aws_cloudwatch_metric_alarm" "alb_high_response_time" {
  alarm_name          = "${var.project_name}-alb-slow-response"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "ALB response time is too slow (2s)"
  dimensions          = { LoadBalancer = var.alb_arn_suffix }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_high_5xx" {
  alarm_name          = "${var.project_name}-alb-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "ALB 5XX error rate is too high"
  dimensions          = { LoadBalancer = var.alb_arn_suffix }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

###############################################################
# CloudWatch Alarms - Running Tasks
###############################################################
resource "aws_cloudwatch_metric_alarm" "no_running_tasks_api_gateway" {
  alarm_name          = "${var.project_name}-api-gateway-no-running-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "API Gateway has no running tasks"
  dimensions          = { ServiceName = "${var.project_name}-api-gateway-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "no_running_tasks_user_service" {
  alarm_name          = "${var.project_name}-user-service-no-running-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "User Service has no running tasks"
  dimensions          = { ServiceName = "${var.project_name}-user-service-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "no_running_tasks_product_service" {
  alarm_name          = "${var.project_name}-product-service-no-running-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Product Service has no running tasks"
  dimensions          = { ServiceName = "${var.project_name}-product-service-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "no_running_tasks_order_service" {
  alarm_name          = "${var.project_name}-order-service-no-running-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Order Service has no running tasks"
  dimensions          = { ServiceName = "${var.project_name}-order-service-service", ClusterName = "${var.project_name}-cluster" }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

###############################################################
# CloudWatch Dashboard
###############################################################
resource "aws_cloudwatch_dashboard" "production_health" {
  dashboard_name = "${var.project_name}-production-health"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "text", x = 0, y = 0, width = 24, height = 2
        properties = { markdown = "## Production Health Dashboard\n\nGolden Signals: **Latency** - **Traffic** - **Errors** - **Saturation**" }
      },
      {
        type = "metric", x = 0, y = 2, width = 6, height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { "label" : "Total Requests" }],
            [".", "HTTPCode_Target_2XX_Count", ".", ".", { "stat" : "Sum", "label" : "Success" }]
          ]
          period = 300, stat = "Sum", region = var.region
          title = "Availability (SLA 99.9%)", view = "gauge"
        }
      },
      {
        type = "metric", x = 6, y = 2, width = 6, height = 6
        properties = {
          metrics = [["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]]
          period = 300, stat = "Average", region = var.region
          title = "Response Time (P95)"
        }
      },
      {
        type = "metric", x = 12, y = 2, width = 6, height = 6
        properties = {
          metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { "stat" : "Sum", "period" : 60, "label" : "Requests/min" }]]
          period = 60, stat = "Sum", region = var.region
          title = "Traffic (RPS)"
        }
      },
      {
        type = "metric", x = 18, y = 2, width = 6, height = 6
        properties = {
          metrics = [["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { "stat" : "Sum", "label" : "5XX Errors" }]]
          period = 300, stat = "Sum", region = var.region
          title = "Error Rate (5XX)"
        }
      },
      {
        type = "text", x = 0, y = 8, width = 24, height = 2
        properties = { markdown = "## Service Performance Trends" }
      },
      {
        type = "metric", x = 0, y = 10, width = 12, height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.project_name}-api-gateway-service", "ClusterName", "${var.project_name}-cluster"],
            [".", ".", ".", "${var.project_name}-user-service-service", ".", ".", { "stat" : "Average" }],
            [".", ".", ".", "${var.project_name}-product-service-service", ".", ".", { "stat" : "Average" }],
            [".", ".", ".", "${var.project_name}-order-service-service", ".", ".", { "stat" : "Average" }]
          ]
          period = 300, stat = "Average", region = var.region
          title = "ECS Services CPU Utilization (%)"
        }
      },
      {
        type = "metric", x = 12, y = 10, width = 12, height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", "${var.project_name}-api-gateway-service", "ClusterName", "${var.project_name}-cluster"],
            [".", ".", ".", "${var.project_name}-user-service-service", ".", ".", { "stat" : "Average" }],
            [".", ".", ".", "${var.project_name}-product-service-service", ".", ".", { "stat" : "Average" }],
            [".", ".", ".", "${var.project_name}-order-service-service", ".", ".", { "stat" : "Average" }]
          ]
          period = 300, stat = "Average", region = var.region
          title = "ECS Services Memory Utilization (%)"
        }
      },
      {
        type = "text", x = 0, y = 16, width = 24, height = 2
        properties = { markdown = "## ALB Performance" }
      },
      {
        type = "metric", x = 0, y = 18, width = 12, height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { "stat" : "Sum", "label" : "Request Count" }],
            [".", "TargetResponseTime", ".", ".", { "stat" : "Average", "label" : "Response Time (s)" }]
          ]
          period = 300, region = var.region
          title = "ALB Request Count & Response Time"
        }
      },
      {
        type = "metric", x = 12, y = 18, width = 12, height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", var.alb_arn_suffix],
            [".", "HTTPCode_Target_4XX_Count", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          period = 300, stat = "Sum", region = var.region
          title = "ALB HTTP Status Codes"
        }
      },
      {
        type = "text", x = 0, y = 24, width = 24, height = 2
        properties = { markdown = "## Resource Saturation" }
      },
      {
        type = "metric", x = 0, y = 26, width = 12, height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ServiceName", "${var.project_name}-api-gateway-service", "ClusterName", "${var.project_name}-cluster"],
            [".", ".", ".", "${var.project_name}-user-service-service", ".", "."],
            [".", ".", ".", "${var.project_name}-product-service-service", ".", "."],
            [".", ".", ".", "${var.project_name}-order-service-service", ".", "."]
          ]
          period = 60, stat = "Average", region = var.region
          title = "Running Tasks per Service"
        }
      }
    ]
  })
}
