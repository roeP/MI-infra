data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket   = "mi-terraform-state-bucket"
    region = "us-east-1"
    key = "eks.state"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}
