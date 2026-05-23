output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "The ID of the shared public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the shared private route table."
  value       = aws_route_table.private.id
}

output "nat_gateway_id" {
  description = "The ID of the single shared NAT Gateway."
  value       = aws_nat_gateway.this.id
}
