locals {
  common_tags = {
    Environment = var.project.environment
    Project     = var.project.name
    ManagedBy   = "terraform"
    Stack       = "ci-cd"
  }
}
