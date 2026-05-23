resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project.name}-${var.project.environment}-nat-eip"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project.name}-${var.project.environment}-nat-gw"
  }

  depends_on = [
    aws_internet_gateway.this,
    aws_subnet.public,
  ]
}
