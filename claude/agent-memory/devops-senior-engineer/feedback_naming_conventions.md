---
name: Project Terraform Naming Conventions
description: Mandatory naming conventions for all Terraform stacks in this project
type: feedback
---

Apply these conventions to every Terraform stack in this project without exception.

**File naming:** Use dot-separated semantic hierarchy. VPC-related files: `vpc.tf`, `vpc.public-subnets.tf`, `vpc.private-subnets.tf`, `vpc.public-route-table.tf`, `vpc.private-route-table.tf`, `vpc.nat-gateway.tf`, `vpc.flow-logs.tf`. Other stacks follow the same pattern (e.g. `eks.node-group.tf`).

**Resource logical names:** Never repeat the resource type in the identifier. Use `this` for unambiguous singletons. Use semantic names (`public`, `private`) when multiple instances exist of the same type. Wrong: `aws_route_table.public_route_table`. Correct: `aws_route_table.public`.

**Block attribute ordering:** `count`/`for_each` always first. `tags` always last (before `depends_on`/`lifecycle`).

**Variables:** Consolidate standalone variables into grouped objects by context (`var.vpc`, `var.project`). No `default` on any variable. Attribute order: `description`, `type`, `nullable`, `validation`.

**Outputs:** Pattern `{name}_{type}_{attribute}`. Always include `description`. Plural names for list outputs.

**Tfvars:** Never use root `terraform.tfvars`. Always use `envs/dev.tfvars`, `envs/staging.tfvars`, `envs/production.tfvars`.

**Why:** Project-wide rule established by the Architect Agent and applied during the 2026-05-23 networking stack refactor.

**How to apply:** Before writing any new Terraform resource, variable, output, or file in this repo, verify compliance with all rules above.
