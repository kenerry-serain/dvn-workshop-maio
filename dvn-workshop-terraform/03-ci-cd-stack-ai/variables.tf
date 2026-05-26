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

variable "github_actions" {
  description = "Configuration for the GitHub Actions OIDC provider and IAM role."
  type = object({
    oidc_provider_url   = string
    github_org          = string
    github_repo         = string
    allowed_branches    = list(string)
    role_name           = string
    ecr_repository_arns = list(string)
  })
  nullable = false
}
