---
name: ADR-0002 Remote Backend Stack
description: remote-backend/ stack provisions S3 for Terraform remote state; use_lockfile=true (no DynamoDB); state is local by design
type: project
---

The `remote-backend/` stack (no numeric prefix, always excluded from bulk deploys) was implemented per ADR-0002 on 2026-05-23.

- Bucket: `dvn-workshop-production-terraform-state` in `us-east-1`
- 5 resources: `aws_s3_bucket`, `aws_s3_bucket_versioning`, `aws_s3_bucket_server_side_encryption_configuration`, `aws_s3_bucket_public_access_block`, `aws_s3_bucket_lifecycle_configuration`
- S3 native locking (`use_lockfile = true`) — no DynamoDB table
- SSE-S3 (AES256), all public access blocked, versioning enabled, noncurrent versions expire after 90 days
- State for this stack is deliberately local (chicken-and-egg)
- Key convention for consuming stacks: `<semantic-stack-name>/terraform.tfstate`

**Why:** ADR-0002 chose S3 native locking as the AWS Prescriptive Guidance recommended approach for Terraform >= 1.10.0, eliminating DynamoDB dependency.

**How to apply:** When implementing consuming stacks (e.g. 01-networking-stack-ai), add the backend block to their versions.tf and run `terraform init -migrate-state`. The bucket name and region are exposed as outputs `s3_bucket_id` and `s3_bucket_region`.

## MCP validation finding (important)
`bucket_key_enabled` in `aws_s3_bucket_server_side_encryption_configuration` is a sibling of `apply_server_side_encryption_by_default` inside the `rule` block — NOT nested inside `apply_server_side_encryption_by_default`. ADR guideline was slightly imprecise; provider schema (doc 12311377) is authoritative.
