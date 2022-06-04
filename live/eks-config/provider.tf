provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "arn:aws:eks:us-east-1:699826842731:cluster/mi"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:us-east-1:699826842731:cluster/mi"
}

provider "aws" {
  region = "us-east-1"
}
