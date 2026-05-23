# -----------------------------------------------------------------------------
# 01-networking-stack-ai
# -----------------------------------------------------------------------------
# This stack provisions a production-ready VPC with public and private subnets
# across multiple Availability Zones, following AWS Well-Architected best
# practices validated via AWS MCP (skill: creating-production-vpc-multi-az).
#
# Architecture Decision Record: ADR-0001-networking-stack-vpc-multi-az.md
# -----------------------------------------------------------------------------

locals {
  az_count = length(var.availability_zones)

  # Determine how many NAT Gateways to create
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.az_count) : 0

  # Common resource name prefix
  name_prefix = var.vpc_name
}
