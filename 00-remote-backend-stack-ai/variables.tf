variable "aws_region" {
  description = "AWS region where all resources will be provisioned."
  type        = string
  nullable    = false
}

variable "project" {
  description = "Configuracoes do projeto."
  type = object({
    name        = string
    environment = string
  })
  nullable = false
}

variable "backend" {
  description = "Configuracoes do bucket S3 para armazenamento remoto de state files."
  type = object({
    bucket_name                        = string
    noncurrent_version_expiration_days = number
  })
  nullable = false
}
