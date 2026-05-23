resource "aws_subnet" "private" {
  count = length(var.vpc.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.vpc.private_subnet_cidrs[count.index]
  availability_zone = var.vpc.availability_zones[count.index]

  tags = {
    Name = "${var.project.name}-${var.project.environment}-private-subnet-${count.index + 1}"
    Tier = "private"
  }
}
