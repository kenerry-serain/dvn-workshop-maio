---
name: ADR-0003 EKS Stack
description: EKS cluster stack in 02-eks-stack-ai/; consumes networking remote state; key implementation details for future stacks
type: project
---

Stack `02-eks-stack-ai` implements ADR-0003: EKS 1.31 managed node group (2x t3.medium ON_DEMAND) in private subnets.

**Why:** Workshop needs a Kubernetes platform built on top of the VPC from stack 01. Consumes VPC outputs (`vpc_id`, `private_subnet_ids`) via `data.terraform_remote_state.networking`.

**How to apply:** When building stacks that need the EKS cluster (e.g., application deployments, ALB ingress), reference `eks/terraform.tfstate` in S3 bucket `dvn-workshop-production-terraform-state`. Available outputs: `eks_cluster_name`, `eks_cluster_endpoint`, `eks_cluster_certificate_authority_data`, `eks_cluster_security_group_id`, `eks_node_iam_role_arn`.

Key implementation details:
- S3 backend key: `eks/terraform.tfstate`
- Provider: `hashicorp/aws ~> 6.0` (resolved to 6.46.0)
- Cluster IAM role trust policy includes both `sts:AssumeRole` AND `sts:TagSession` (required for EKS)
- Node group `depends_on` all three node policy attachments explicitly (Terraform IAM propagation requirement)
- Addons (vpc-cni, coredns, kube-proxy) all `depends_on = [aws_eks_node_group.this]` — coredns needs running nodes
- `access_config.authentication_mode = "API_AND_CONFIG_MAP"`
- No IRSA/OIDC provider in this iteration — planned for a future ADR
