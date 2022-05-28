data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_ami" "amzn-ami-eks" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amazon-eks-node-${var.cluster_version}-*"
    ]
  }
}

data "aws_iam_policy_document" "federated_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = ["${aws_iam_openid_connect_provider.oidc_provider.arn}"]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "template_file" "userdata" {
  for_each = var.workers
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name         = aws_eks_cluster.this.name
    endpoint             = aws_eks_cluster.this.endpoint
    cluster_auth_base64  = aws_eks_cluster.this.certificate_authority[0].data
    bootstrap_extra_args = ""
    kubelet_extra_args   = "${each.value.kubelet_extra_args}"
  }
}

data "aws_subnet_ids" "app" {
  vpc_id = var.vpc_id

  tags = {
    Tier = "App"
  }
}

data "aws_subnet_ids" "web" {
  vpc_id = var.vpc_id

  tags = {
    Tier = "Web"
  }
}

#data "template_file" "config_map_aws_auth" {
#  template = file("${path.module}/templates/config-map-aws-auth.yaml.tpl")
#
#  vars = {
#    worker_role_arn = aws_iam_role.workers.arn
#  }
#}
