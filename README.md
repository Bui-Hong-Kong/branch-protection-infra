# branch-protection-infra

Terraform / infrastructure repo for the **branch-protection** lab (org `Bui-Hong-Kong`).

This repository holds **infrastructure-as-code only**. Application code lives in [`branch-protection`](https://github.com/Bui-Hong-Kong/branch-protection).

## Scope

| Area | Notes |
| --- | --- |
| ECR | One AWS account; per Sock Shop service × env (`sockshop-<service>-env-1/2`) |
| Platform | Shared **1 VPC + 1 EKS** (`platform/`) for all app namespaces |
| State | Remote: S3 bucket and S3 lockfile (bucket created by `bootstrap/`) |
| Image flow | Build/push each service to env-1; crane-copy same tag to env-2 |
| Workloads | Kubernetes manifests / Argo CD — add next (not in Terraform yet) |
| CI | PR checks for Terraform; apply only via manual workflow on `main` |

## Layout

```text
.
├── README.md
├── .gitignore
├── .checkov.yaml
├── .github/
│   ├── ruleset-main.json
│   └── workflows/
│       ├── 01-terraform-check.yml
│       └── 02-terraform-apply.yml
├── bootstrap/                     # state backend + GHA IAM (local state)
│   ├── iam.tf                     # gha-terraform (ECR stacks)
│   └── iam_platform.tf            # gha-platform (VPC/EKS)
├── platform/                      # shared VPC + EKS + IRSA (iam.tf)
│   ├── platform.conf
│   └── platform.tfvars
├── main.tf                        # ECR env stacks
├── env-1.conf
├── env-2.conf
├── env/
│   ├── env-1.tfvars
│   └── env-2.tfvars
└── modules/services/ecr/
```

- **Root** = ECR per environment (`env-1` / `env-2`).
- **`platform/`** = one shared compute network (apply once).
- **`bootstrap/`** = separate root (local state).

## Branch protection and CI

`main` is protected by ruleset `protect-main` (see `.github/ruleset-main.json`):

- No direct push / force-push / delete
- Changes via pull request
- Required checks: `Format (terraform)`, `Validate (root)`, `Validate (bootstrap)`, `Validate (platform)`, `Security (terraform)`
- Branch must be up to date with `main`

**Apply to AWS** is not automatic on merge. After merging to `main`, run **Actions → 2. Terraform apply** and choose `env-1`, `env-2`, `both`, or `platform`.

Set repo variables (not secrets) from `bootstrap/` outputs:

- `AWS_ROLE_ARN` = `github_actions_role_arn` (ECR env stacks)
- `AWS_ROLE_ARN_PLATFORM` = `github_actions_platform_role_arn` (VPC/EKS platform)

After adding `Validate (platform)`, update the GitHub ruleset once so the new check is required (JSON in-repo is the source of truth to re-import).

## Prerequisites

- Terraform `1.15.7`
- AWS CLI for local bootstrap only
- Default region: `ap-southeast-1`

Do not commit secrets, access keys, or `bootstrap/terraform.tfvars`. `env/*.tfvars` and `platform/platform.tfvars` only hold non-secret config.

## Apply order

### 1. Bootstrap (once, local)

```bash
cd bootstrap
terraform init
terraform apply
terraform output
cd ..
```

Re-apply bootstrap when IAM changes. Platform permissions live in `bootstrap/iam_platform.tf` (role `gha-platform`); ECR stack permissions stay in `bootstrap/iam.tf` (`gha-terraform`).

### 2. Platform (shared VPC + EKS)

On `main`: **2. Terraform apply** → `platform`.

Local:

```bash
cd platform
terraform init -reconfigure -backend-config=platform.conf
terraform apply -var-file=platform.tfvars
aws eks update-kubeconfig --region ap-southeast-1 --name branch-protection-eks
```

Creates:

- VPC (`10.40.0.0/16`), 2 AZ, 1 NAT
- EKS `branch-protection-eks` (v1.31) + managed node group (`t3.medium` × 2)
- IRSA role for **AWS Load Balancer Controller** (Helm/Argo install later)

### 3. ECR environment stacks

On `main`: **2. Terraform apply** → `both` (or one env).

```bash
terraform init -reconfigure -backend-config=env-1.conf
terraform apply -var-file=env/env-1.tfvars
```

## Security check

| Question | Answer |
| --- | --- |
| Where are secrets stored? | Not in this repo — OIDC role from `bootstrap/` for CI |
| Who can access? | Org members with repo access + least-privilege cloud roles |
| Rotation / revocation | Rotate cloud credentials and CI tokens out-of-band |
| Committed to git? | **No** — never commit real secrets or `*.tfstate` |
| State bucket | Private, SSE, versioning, block public access (see `bootstrap/`) |
| Platform IAM in GHA role | Broad lab permissions for EC2/EKS/IAM — tighten later if needed |

## ECR naming

```text
sockshop-<service>-env-1   # push target
sockshop-<service>-env-2   # promote target (crane copy)
```

## Status

ECR stacks + platform Terraform (VPC/EKS/IRSA). Next: ALB controller + Argo CD + app/DB manifests per namespace.
