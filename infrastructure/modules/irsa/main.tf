locals {
  oidc_issuer = replace(var.oidc_issuer_url, "https://", "")
}

###############################################################
# 공통: IRSA assume role policy 팩토리
###############################################################
data "aws_iam_policy_document" "assume" {
  for_each = var.service_accounts

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${each.key}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "service" {
  for_each = var.service_accounts

  name               = "${var.project_name}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.assume[each.key].json
}

###############################################################
# api-gateway: SSM 읽기 (JWT secret, DB password 등)
###############################################################
resource "aws_iam_role_policy" "api_gateway_ssm" {
  name = "ssm-read"
  role = aws_iam_role.service["api-gateway"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
      Resource = "arn:aws:ssm:${var.region}:*:parameter/${var.project_name}/*"
    }]
  })
}

###############################################################
# user-service: SSM 읽기
###############################################################
resource "aws_iam_role_policy" "user_service_ssm" {
  name = "ssm-read"
  role = aws_iam_role.service["user-service"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
      Resource = "arn:aws:ssm:${var.region}:*:parameter/${var.project_name}/*"
    }]
  })
}

###############################################################
# product-service: SSM 읽기 + S3 이미지 업로드
###############################################################
resource "aws_iam_role_policy" "product_service_ssm" {
  name = "ssm-read"
  role = aws_iam_role.service["product-service"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
      Resource = "arn:aws:ssm:${var.region}:*:parameter/${var.project_name}/*"
    }]
  })
}

resource "aws_iam_role_policy" "product_service_s3" {
  name = "s3-image-upload"
  role = aws_iam_role.service["product-service"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
      ]
      Resource = "arn:aws:s3:::${var.project_name}-*/*"
    }]
  })
}

###############################################################
# order-service: SSM 읽기
###############################################################
resource "aws_iam_role_policy" "order_service_ssm" {
  name = "ssm-read"
  role = aws_iam_role.service["order-service"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
      Resource = "arn:aws:ssm:${var.region}:*:parameter/${var.project_name}/*"
    }]
  })
}
