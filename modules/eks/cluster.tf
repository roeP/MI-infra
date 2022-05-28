resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  tags = merge(
    var.tags,
    {
      "Name" = "${local.cluster_name}-cloudwatch"
    },
  )

}

resource "aws_eks_fargate_profile" "fargate" {
  count                  = var.enable_fargate
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "fargate-eks-profile"
  pod_execution_role_arn = aws_iam_role.fargate[count.index].arn
  subnet_ids             = tolist(data.aws_subnet_ids.app.ids)

  dynamic "selector" {
    for_each = var.fargate_namespaces
    content {
      namespace = selector.value
    }
  }
}

resource "aws_iam_role" "fargate" {
  count = var.enable_fargate
  name  = "eks-fargate-profile"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSFargatePodExecutionRolePolicy" {
  count      = var.enable_fargate
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate[count.index].name
}

resource "aws_eks_cluster" "this" {
  name                      = local.cluster_name
  role_arn                  = aws_iam_role.cluster.arn
  version                   = var.cluster_version
  enabled_cluster_log_types = ["api", "authenticator", "controllerManager", "scheduler"]
  tags = merge(
    var.tags,
    {
      "Name" = "${local.cluster_name}"
    },
  )

  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = tolist(data.aws_subnet_ids.app.ids)
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
  }
}

resource "aws_security_group" "cluster" {
  name_prefix = local.cluster_name
  description = "EKS cluster security group."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = "${local.cluster_name}-eks_cluster_sg"
    },
  )
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_ingress_office" {
  description       = "Allow workers pods to receive communication from the cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["192.168.0.0/16"]
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_ingress_mobile" {
  description       = "Allow access from jenkins mobile"
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["10.174.0.0/16"]
  from_port         = 443
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_ingress_apps" {
  description       = "Allow access from jenkins apps"
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["10.243.0.0/16"]
  from_port         = 443
  to_port           = 443
  type              = "ingress"
}

resource "aws_iam_role" "cluster" {
  name_prefix           = local.cluster_name
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  force_detach_policies = true
  tags = merge(
    var.tags,
    {
      "Name" = "${local.cluster_name}-iam-role"
    },
  )
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}
