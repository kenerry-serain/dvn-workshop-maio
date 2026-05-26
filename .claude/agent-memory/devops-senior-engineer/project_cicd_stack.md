---
name: ADR-0004/0005/0006 CI/CD Stack
description: OIDC/IAM Terraform stack, ArgoCD GitOps manifests, and GitHub Actions workflow — implemented 2026-05-24
type: project
---

Stack `03-ci-cd-stack-ai` implements GitHub Actions OIDC federation to AWS.

**Why:** Eliminates long-lived AWS credentials in GitHub; tokens are scoped to `repo:kenerry-serain/dvn-workshop-maio:ref:refs/heads/main` only.

**Key facts:**
- Backend S3 key: `ci-cd/terraform.tfstate`
- OIDC provider: `https://token.actions.githubusercontent.com` — `thumbprint_list` omitted (AWS trusts GitHub CAs natively, confirmed via Terraform MCP doc 12310858)
- IAM role name: `dvn-workshop-github-actions-role`
- ECR push permissions scoped to `arn:aws:ecr:us-east-1:654654554686:repository/dvn-workshop/production/backend` and `.../frontend`
- `lifecycle { prevent_destroy = true }` on `aws_iam_openid_connect_provider.github`
- Trust policy `sub` condition is dynamic — driven by `allowed_branches` list in tfvars, converts to `repo:<org>/<repo>:ref:refs/heads/<branch>` strings

**ArgoCD:**
- `dvn-workshop-kubernetes/argocd-application.yaml` — Application CRD pointing to `dvn-workshop-kubernetes/` path, auto-sync with prune+selfHeal
- NOT included in `kustomization.yaml` resources — must be applied as a one-time bootstrap step via `kubectl apply`; including it would create a self-referential management loop

**GitHub Actions workflow:**
- `.github/workflows/ci-cd.yml`
- Separate conditional jobs (`build-backend`, `build-frontend`) — not matrix — for cleaner conditionals
- `vars.AWS_ROLE_ARN` (GitHub Actions variable, not secret) must be set manually after Terraform deploy
- Tag strategy: `sha-$(echo $GITHUB_SHA | cut -c1-7)`
- `[skip ci]` in kustomization commit message prevents loop re-trigger
- `update-kustomization` uses `if: always() && ...` to run when either or both builds succeed

**How to apply:** Run `terraform-deploy 03-ci-cd-stack-ai` once AWS credentials are active; then bootstrap ArgoCD manually.
