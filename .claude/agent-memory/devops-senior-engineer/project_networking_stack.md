---
name: ADR-0001 Networking Stack Implementation
description: Context for the VPC networking stack implemented from ADR-0001 in 01-networking-stack-ai/
type: project
---

ADR-0001 networking stack was implemented on 2026-05-23 in `01-networking-stack-ai/` and refactored on 2026-05-23 to comply with project naming conventions.

**Stack resources:** VPC (var.vpc.cidr), internet gateway, 3 public subnets, 3 private subnets (across var.vpc.availability_zones), 3 NAT Gateways (one per AZ), VPC Flow Logs to CloudWatch, public and private route tables with associations.

**Why:** This is the foundational networking layer. All future stacks (EKS, RDS, ALB) consume outputs from this stack via `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `nat_gateway_ids`.

**Naming conventions applied:**
- Resource logical names: `this` for singletons (`aws_vpc.this`, `aws_internet_gateway.this`, `aws_nat_gateway.this`, `aws_flow_log.this`); semantic names for resources needing distinction (`aws_subnet.public`, `aws_subnet.private`, `aws_route_table.public`, `aws_route_table.private`).
- Variables consolidated into two objects: `var.vpc` (cidr, name, subnet CIDRs, AZs, flow log settings) and `var.project` (name, environment). Plus `var.aws_region` as a standalone. No defaults on any variable.
- Tfvars split into `envs/dev.tfvars`, `envs/staging.tfvars`, `envs/production.tfvars`. Root `terraform.tfvars` deleted.
- File layout: `vpc.tf`, `vpc.public-subnets.tf`, `vpc.private-subnets.tf`, `vpc.public-route-table.tf`, `vpc.private-route-table.tf`, `vpc.nat-gateway.tf`, `vpc.flow-logs.tf`, plus `main.tf`, `variables.tf`, `outputs.tf`, `tags.tf`, `versions.tf`.

**How to apply:** When implementing downstream stacks, reference outputs from this stack. Provider pinned to hashicorp/aws ~> 6.0 (resolved to v6.46.0). `terraform validate` passes after refactor. Apply with `terraform apply -var-file=envs/dev.tfvars` (or the target environment). `terraform plan` and human approval required before `apply` in staging/production.
