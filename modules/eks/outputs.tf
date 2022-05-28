output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "workers_sg" {
  value = aws_security_group.workers.id
}

output "cluster_sg" {
  value = aws_security_group.cluster.id
}

output "workers_iam_arn" {
  value = aws_iam_role.workers.arn
}

output "alb_iam_role" {
  value = aws_iam_role.alb_controller_iam_role.arn
}

output "oicd_url" {
  value = aws_iam_openid_connect_provider.oidc_provider.url
}

output "oicd_arn" {
  value = aws_iam_openid_connect_provider.oidc_provider.arn
}
