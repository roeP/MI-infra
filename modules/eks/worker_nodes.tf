resource "aws_launch_template" "launch_template" {
  for_each = var.workers
  name          = "${each.value.name}-launch-template"
  image_id      = data.aws_ami.amzn-ami-eks.id
  instance_type = "t3.micro"
  key_name      = var.ssh_key
  user_data     = base64encode(data.template_file.userdata[each.key].rendered)

  iam_instance_profile {
    name = aws_iam_instance_profile.worker-instance-profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.workers.id}"]
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "${data.aws_ami.amzn-ami-eks.root_device_name}"
    ebs {
      delete_on_termination = true
      encrypted             = false
      snapshot_id           = data.aws_ami.amzn-ami-eks.root_snapshot_id
      volume_size           = each.value.volume_size
      volume_type           = data.aws_ami.amzn-ami-eks.block_device_mappings.*.ebs[0].volume_type
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-worker"
    },
  )

}


resource "aws_iam_instance_profile" "worker-instance-profile" {
  name = "${var.cluster_name}-instance-profile"
  role = aws_iam_role.workers.name
}

resource "aws_security_group" "workers" {
  name        = "${aws_eks_cluster.this.name}-workers-sg"
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                               = "${aws_eks_cluster.this.name}-worker-sg"
      "kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_office" {
  description       = "Allow me to receive communication from the cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers.id
  cidr_blocks       = ["62.219.194.102/32"]
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_ingress_workers" {
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_iam_role" "workers" {
  name                  = "${var.cluster_name}-worker-role"
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  force_detach_policies = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-worker-role"
    },
  )
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}


resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name        = "eks-worker-autoscaling-${aws_eks_cluster.this.name}"
  description = "EKS worker node autoscaling policy for cluster ${aws_eks_cluster.this.name}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
}


resource "aws_placement_group" "placement_group" {
  name     = "${var.cluster_name}-placement-group"
  strategy = "spread"
}

resource "aws_autoscaling_group" "auto-scaling" {
  for_each = var.workers
  name                      = "${each.value.name}-autoscaling"
  desired_capacity          = each.value.desired_capacity
  max_size                  = each.value.max_capacity
  min_size                  = each.value.min_capacity
  default_cooldown          = 60
  placement_group           = aws_placement_group.placement_group.id
  health_check_grace_period = 30
  health_check_type         = "EC2"
  vpc_zone_identifier       = tolist(data.aws_subnet_ids.subnets.ids)
  termination_policies      = ["OldestInstance"]
  wait_for_capacity_timeout = "10m"
  suspended_processes       = ["AZRebalance"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy            = "prioritized"
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = each.value.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 4
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template[each.key].id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = each.value.spot_instance_types

        content {
          instance_type = override.value
        }
      }
    }
  }

  tags = [
    {
      "key"                 = "Name"
      "value"               = "${each.value.name}-worker"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "kubernetes.io/cluster/${aws_eks_cluster.this.name}"
      "value"               = "owned"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "k8s.io/cluster-autoscaler/enabled"
      "value"               = "true"
      "propagate_at_launch" = false
    },
    {
      "key"                 = "k8s.io/cluster-autoscaler/${aws_eks_cluster.this.name}"
      "value"               = aws_eks_cluster.this.name
      "propagate_at_launch" = false
    },
    {
      "key"                 = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
      "value"               = "100"
      "propagate_at_launch" = false
    }
  ]

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
