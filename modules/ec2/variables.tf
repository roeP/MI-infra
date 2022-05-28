variable "jenkins_version" {
  description = "jenkins version to use on the docker image."
  type        = string
  default     = "lts-jdk11"
}

# variable "efs_endpoint" {
#   description = "efs persistant"
#   type        = string
# }

variable "ssh_key" {
  type        = string
}

variable "vpc_id" {
  default = "vpc-08d8e93108fef1c9d"
}