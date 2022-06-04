output "cluster_name" {
  value = module.self.cluster_name
}

output "workers_iam_arn" {
  value = module.self.workers_iam_arn
}


output "alb_iam_arn" {
  value = module.self.alb_iam_role
}