variable "aws_region" {
  description = "AWS region where all resources will be provisioned."
  type        = string
  nullable    = false
}

variable "project" {
  description = "Project settings shared across resources."
  type = object({
    name        = string
    environment = string
  })
  nullable = false
}

variable "ecr" {
  description = "Configuration for ECR repositories."
  type = object({
    repository_names     = list(string)
    image_tag_mutability = string
    scan_on_push         = bool
    force_delete         = bool
  })
  nullable = false
}

variable "eks" {
  description = "Configuration for the EKS cluster and managed node group."
  type = object({
    cluster_name    = string
    cluster_version = string
    node_group = object({
      name           = string
      instance_types = list(string)
      capacity_type  = string
      ami_type       = string
      desired_size   = number
      min_size       = number
      max_size       = number
      disk_size      = number
    })
    cluster_log_types       = list(string)
    endpoint_private_access = bool
    endpoint_public_access  = bool
  })
  nullable = false
}
