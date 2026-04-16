locals {
  oidc_issuer = replace(var.oidc_issuer_url, "https://", "")
}

###############################################################
# External Secrets Operator - IRSA
# ESO가 SSM Parameter Store에서 값을 읽어 K8s Secret 생성
###############################################################
resource "aws_iam_role" "external_secrets" {
  name = "${var.project_name}-external-secrets"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "external_secrets_ssm" {
  name = "ssm-read"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters",
        ]
        Resource = "arn:aws:ssm:${var.region}:*:parameter/${var.project_name}/*"
      },
      {
        # KMS 복호화 (SecureString 파라미터)
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = "arn:aws:kms:${var.region}:*:key/*"
        Condition = {
          StringLike = { "kms:ViaService" = "ssm.${var.region}.amazonaws.com" }
        }
      }
    ]
  })
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.eso_chart_version

  values = [
    yamlencode({
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
        }
      }
      # 시스템 노드에서 실행
      tolerations = [{
        key      = "CriticalAddonsOnly"
        operator = "Exists"
        effect   = "NoSchedule"
      }]
      nodeSelector = { role = "system" }
    })
  ]
}

###############################################################
# Argo CD
###############################################################
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version

  values = [
    yamlencode({
      global = {
        # 시스템 노드에서 실행
        tolerations = [{
          key      = "CriticalAddonsOnly"
          operator = "Exists"
          effect   = "NoSchedule"
        }]
        nodeSelector = { role = "system" }
      }

      configs = {
        params = {
          # ALB(HTTPS)가 TLS 종료하므로 argocd-server는 HTTP 모드
          "server.insecure" = true
        }
        secret = var.argocd_admin_password_hash != "" ? {
          argocdServerAdminPassword = var.argocd_admin_password_hash
        } : {}
      }

      server = {
        # ALB Ingress는 k8s/system/argocd-ingress.yaml 에서 관리
        ingress = { enabled = false }
      }

      # HA 불필요 (비용 절감) - application-controller만 1 replica
      applicationSet = { replicaCount = 1 }
      dex            = { enabled = false }   # SSO 불사용
    })
  ]
}
