resource "aws_eks_cluster" "this" {
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.cluster.arn
  version                   = var.cluster_version
  enabled_cluster_log_types = ["api"]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}"
    },
  )

  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = tolist(data.aws_subnet_ids.subnets.ids)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  timeouts {
    create = var.cluster_create_timeout
  }
}



resource "aws_security_group" "cluster" {
  name_prefix = var.cluster_name
  description = "EKS cluster security group."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-eks_cluster_sg"
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

resource "aws_security_group_rule" "cluster_ingress_home" {
  description       = "Allow me to receive communication from the cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["62.219.194.102/32"]
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "vpc_traffic" {
  description              = "Allow vpc traffic"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  cidr_blocks              = [data.aws_vpc.selected.cidr_block]
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}