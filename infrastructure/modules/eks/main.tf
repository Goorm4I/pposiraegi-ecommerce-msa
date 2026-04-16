###############################################################
# IAM - EKS Cluster Role
###############################################################
resource "aws_iam_role" "cluster" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

###############################################################
# IAM - Node Group Role (시스템 노드용)
###############################################################
resource "aws_iam_role" "node" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EBS CSI Driver 권한 (PVC 사용 시 필요)
resource "aws_iam_role_policy_attachment" "node_ebs_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

###############################################################
# EKS Cluster
###############################################################
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = [
      var.private_subnet_a_id,
      var.private_subnet_b_id,
      var.public_subnet_a_id,
      var.public_subnet_b_id,
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Container Insights 활성화
  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  tags = { Name = "${var.project_name}-cluster" }

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

###############################################################
# OIDC Provider (IRSA 필수)
###############################################################
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

###############################################################
# EKS Addons
###############################################################
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "vpc-cni"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "coredns"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.system]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "kube-proxy"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.system]
}

###############################################################
# System Node Group (Karpenter / Argo CD / 시스템 파드용)
# Karpenter가 관리하는 앱 노드와 분리해서 안정성 확보
###############################################################
resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-system-nodes"
  node_role_arn   = aws_iam_role.node.arn

  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]

  instance_types = var.system_node_instance_types

  scaling_config {
    min_size     = var.system_node_min
    max_size     = var.system_node_max
    desired_size = var.system_node_desired
  }

  update_config {
    max_unavailable = 1
  }

  # 시스템 노드임을 표시 - Karpenter가 이 노드는 건드리지 않음
  labels = {
    role = "system"
  }

  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  tags = {
    Name = "${var.project_name}-system-nodes"
    # Karpenter가 이 노드그룹을 발견하도록 태그 (필수)
    "karpenter.sh/discovery" = "${var.project_name}-cluster"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
  ]
}
