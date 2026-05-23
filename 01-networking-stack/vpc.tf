resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "workshop-devops-na-nuvem-vpc"
  }
}