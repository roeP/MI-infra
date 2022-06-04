locals {
  cluster_name = "mi"
  tags = {
    Environment = "test"
  }
  vpc_id  = "vpc-08d8e93108fef1c9d"
  region = "us-east-1"
  ssh_key         = "mi"
  cluster_version = "1.21"
  workers = {
    default_workers = {
      name = "eks-workers"
      spot_instance_types = [
        "t3.micro",
        "t2.micro"
      ]
      min_capacity                             = 1
      desired_capacity                         = 1
      max_capacity                             = 1
      kubelet_extra_args                       = "--registry-qps=0 --register-with-taints=nodeGroupName=apps:NoSchedule --node-labels=nodeGroupName=apps"
      on_demand_percentage_above_base_capacity = 0,
      volume_size                              = 8
    },
    core_servicess = {
      name = "eks-core-services"
      spot_instance_types = [
        "t3.micro",
        "t2.micro"
      ]
      min_capacity                             = 1
      desired_capacity                         = 1
      max_capacity                             = 4
      kubelet_extra_args                       = "--registry-qps=0"
      on_demand_percentage_above_base_capacity = 100,
      volume_size                              = 10
    }
  }
}
