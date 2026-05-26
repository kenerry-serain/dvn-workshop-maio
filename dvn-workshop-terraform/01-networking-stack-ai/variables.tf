variable "aws_region" {
  description = "AWS region where all resources will be provisioned."
  type        = string
  nullable    = false
}

variable "vpc" {
  description = "Configuracoes da VPC."
  type = object({
    name                    = string
    cidr                    = string
    public_subnet_cidrs     = list(string)
    private_subnet_cidrs    = list(string)
    availability_zones      = list(string)
    enable_flow_logs        = bool
    flow_log_retention_days = number
  })
  nullable = false
}

variable "project" {
  description = "Configuracoes do projeto."
  type = object({
    name        = string
    environment = string
  })
  nullable = false
}
