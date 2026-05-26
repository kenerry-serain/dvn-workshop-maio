---
name: CI/CD Pipeline ADRs (0004-0006)
description: Three ADRs produced for CI/CD pipeline — OIDC auth, GitHub Actions, ArgoCD GitOps
type: project
---

ADRs 0004-0006 cover the CI/CD pipeline for dvn-workshop, saved in `docs/` at project root.

- **ADR-0004**: OIDC Provider + IAM Role for GitHub Actions -> AWS authentication (zero long-lived credentials)
- **ADR-0005**: GitHub Actions workflow with path filter, matrix builds, SHA-based tagging, kustomization.yaml auto-commit
- **ADR-0006**: ArgoCD installed via official manifests for GitOps CD on EKS

**Why:** User needs automated CI/CD from GitHub to EKS via ECR, following GitOps pattern with ArgoCD.

**How to apply:** These ADRs are sequential dependencies — 0004 (infra auth) must be implemented before 0005 (pipeline). ArgoCD (0006) can be installed in parallel. The pipeline does NOT deploy directly to EKS; it updates kustomization.yaml and ArgoCD handles sync.

Key decisions:
- New Terraform stack: `03-ci-cd-stack-ai` for OIDC + IAM resources
- Tag strategy: `sha-<7chars>` for traceability
- Kustomization path: `dvn-workshop-kubernetes/kustomization.yaml`
- Account ID: `654654554686`, region: `us-east-1`
- ArgoCD non-HA install (workshop context), port-forward for UI access
