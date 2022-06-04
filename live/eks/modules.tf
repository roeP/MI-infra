module "self" {
  source = "../../modules/eks/"

  cluster_name    = local.cluster_name
  tags            = local.tags
  vpc_id          = data.aws_vpc.selected.id
  ssh_key         = local.ssh_key
  cluster_version = local.cluster_version
  workers         = local.workers
}
