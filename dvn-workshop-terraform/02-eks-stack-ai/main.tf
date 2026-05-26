provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "dvn-workshop-production-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}
