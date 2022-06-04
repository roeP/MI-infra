variable "cluster_log_retention_in_days" {
  default     = 30
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.21"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}

variable "ssh_key" {
  description = "SSH key to be used for conneting to the instance over port 22"
  type        = string
}

variable "on_demand_base_capacity" {
  description = "SSH key to be used for conneting to the instance over port 22"
  type        = number
  default     = 0
}

variable "config_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Assumed to be a directory if the value ends with a forward slash `/`."
  type        = string
  default     = "./"
}

variable "workers" {
  description = "Cluster Workers map"
  type        = map(any)
}

variable "cluster_name" {
   type        = string
}
