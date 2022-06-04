
variable "deploy_role" {
  description = "IAM Role to assume for deployment"
  default     = "arn:aws:iam::003299301968:role/terraform_deployer"
}

variable "terraform_state_region" {
  description = "terraform state region"
  default     = "us-east-1"
}

variable "terraform_state_bucket" {
  description = "terraform state bucket"
  default     = "wm-terraform-applications"
}
