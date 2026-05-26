resource "aws_subnet" "public" {
  count = length(var.vpc.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.vpc.public_subnet_cidrs[count.index]
  availability_zone       = var.vpc.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project.name}-${var.project.environment}-public-subnet-${count.index + 1}"
    Tier = "public"
  }
}
