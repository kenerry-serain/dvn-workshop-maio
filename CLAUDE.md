# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AWS infrastructure workshop using Terraform. Stacks are independent directories prefixed with a two-digit number (e.g. `01-networking-stack-ai`). The `00-remote-backend-stack-ai` stack (if it exists) is always excluded from bulk operations.

## Agents

Two specialized agents are defined in `.claude/agents/`:

- **`devops-solution-architect`** — Plans architectures and produces ADRs only. Never creates `.tf` files or any infrastructure code. Invoked before implementation begins.
- **`devops-senior-engineer`** — Reads ADRs and implements IaC. Invoked after an ADR is approved.

## Deploy Workflow

Use the `terraform-deploy` skill (`.claude/skills/terraform-deploy/`):

```bash
# Deploy a specific stack
/terraform-deploy 01-networking-stack-ai

# Deploy all stacks (sequential, excludes 00-remote-backend-stack-ai)
/terraform-deploy
```

The skill runs: `fmt` → `validate` → `plan` (prints output) → `apply -auto-approve`, always passing `-var-file="envs/production.tfvars"` when present.

## Manual Terraform Commands

```bash
cd 01-networking-stack-ai
terraform fmt
terraform validate
terraform plan  -var-file="envs/production.tfvars"
terraform apply -var-file="envs/production.tfvars"
terraform destroy -var-file="envs/production.tfvars"
```

## MCP Servers

Configured in `.mcp.json`:
- **`terraform`** — Validates provider versions and resources before writing IaC. Always query before citing a provider version or resource.
- **`aws-mcp`** — Validates AWS services, regional availability, and best practices. Always query before citing AWS service behaviour or pricing.

## Documentation Structure

- `docs/` — ADRs produced by the architect agent (`ADR-XXXX-title.md`)
- `docs/implementation/` — Implementation records produced by the engineer agent (`IMPL-ADR-XXXX-YYYY-MM-DD.md`)

## Terraform Conventions

Full rules in `.claude/rules/terraform-naming-conventions.md`. Key points:

**File naming** — dot-separated semantic hierarchy:
```
vpc.tf                    # aws_vpc + aws_internet_gateway
vpc.public-subnets.tf
vpc.private-subnets.tf
vpc.public-route-table.tf
vpc.private-route-table.tf
vpc.nat-gateway.tf
vpc.flow-logs.tf
```

**Variables** — grouped objects, no `default` values:
```hcl
variable "vpc" {
  type = object({
    name                 = string
    cidr                 = string
    public_subnet_cidrs  = list(string)
    private_subnet_cidrs = list(string)
    ...
  })
}
```

**Variable values** — per-environment files, never `terraform.tfvars`:
```
envs/production.tfvars
envs/staging.tfvars
envs/dev.tfvars
```

**Resource identifiers** — no type repetition, always singular:
```hcl
resource "aws_route_table" "public" {}   # correct
resource "aws_route_table" "public_route_table" {}  # wrong
```

**Block ordering** — `count`/`for_each` first, `tags` last (before `depends_on`/`lifecycle`).

**Providers** — native `hashicorp/aws` resources only. No community modules.
