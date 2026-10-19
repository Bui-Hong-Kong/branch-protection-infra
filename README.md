# branch-protection-infra

Terraform / infrastructure repo for the **branch-protection** lab (org `Bui-Hong-Kong`).

This repository holds **infrastructure-as-code only**. Application code lives in [`branch-protection`](https://github.com/Bui-Hong-Kong/branch-protection).

## Scope

| Area | Notes |
| --- | --- |
| ECR | One AWS account; per Sock Shop service × env (`sockshop-<service>-env-1/2`) |
| State | Remote: S3 bucket and S3 lockfile (bucket created by `bootstrap/`) |
| Image flow | Build/push each service to env-1; crane-copy same tag to env-2 — no compute yet |
| Compute | ECS / other runtimes — add later |
| CI | PR checks for Terraform; apply only via manual workflow on `main` |

## Layout

```text
.
├── README.md
├── .gitignore
├── .checkov.yaml
├── .github/
│   ├── ruleset-main.json          # branch ruleset for main (import in GitHub UI / API)
│   └── workflows/
│       ├── 01-terraform-check.yml # PR: fmt / validate / Checkov
│       └── 02-terraform-apply.yml # main: workflow_dispatch apply (OIDC)
├── bootstrap/                     # one-time: state backend + GitHub Actions IAM (local state)
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── env-1.conf
├── env-2.conf
├── env/
│   ├── env-1.tfvars
│   └── env-2.tfvars
└── modules/services/ecr/
```

One root serves both environments. Switch env by re-init with the other `.conf` and `-var-file`. `bootstrap/` stays a separate root.

## Branch protection and CI

`main` is protected by ruleset `protect-main` (see `.github/ruleset-main.json`):

- No direct push / force-push / delete
- Changes via pull request
- Required checks: `Format (terraform)`, `Validate (root)`, `Validate (bootstrap)`, `Security (terraform)`
- Branch must be up to date with `main`

**Apply to AWS** is not automatic on merge. After merging to `main`, run **Actions → 2. Terraform apply** (`workflow_dispatch`) and choose `env-1`, `env-2`, or `both`.

Set repo variable (not a secret) `AWS_ROLE_ARN` = `terraform output -raw github_actions_role_arn` from `bootstrap/` (OIDC role `branch-protection-gha-terraform`).

Enable the ruleset only after the check workflow has run once on a PR (so the status check names exist).

## Prerequisites

- Terraform `1.15.7`
- AWS CLI for local bootstrap only
- Default region: `ap-southeast-1`

Do not commit secrets, access keys, or `bootstrap/terraform.tfvars`. `env/*.tfvars` only hold resource names.

## Apply order

### 1. Bootstrap remote state (once, local)

```bash
cd bootstrap
terraform init
terraform apply
terraform output
cd ..
```

`env-1.conf` and `env-2.conf` are filled for account `975305815837` with `use_lockfile`.

`github_actions_role_arn` → GitHub variable `AWS_ROLE_ARN` on **this** repo. Trust: immutable OIDC subject, `refs/heads/main` only.

`ecr_push_role_arn` / `ecr_copy_role_arn` → app repo `branch-protection` variables.

Bootstrap IAM uses **ECR name wildcards** (`sockshop-*`, `sockshop-*-env-1/2`). Adding or removing services in env stacks does **not** require a bootstrap re-apply.

Bootstrap uses **local state** (gitignored).

### 2. Environment stacks (prefer GitHub Actions)

On `main`: **2. Terraform apply** → `both` (or one env).

Local equivalent (optional):

```bash
terraform init -reconfigure -backend-config=env-1.conf
terraform apply -var-file=env/env-1.tfvars

terraform init -reconfigure -backend-config=env-2.conf
terraform apply -var-file=env/env-2.tfvars
```

## Security check

| Question | Answer |
| --- | --- |
| Where are secrets stored? | Not in this repo — OIDC role from `bootstrap/` for CI |
| Who can access? | Org members with repo access + least-privilege cloud roles |
| Rotation / revocation | Rotate cloud credentials and CI tokens out-of-band |
| Committed to git? | **No** — never commit real secrets or `*.tfstate` |
| State bucket | Private, SSE, versioning, block public access (see `bootstrap/`) |

## ECR naming

```text
sockshop-<service>-env-1   # push target
sockshop-<service>-env-2   # promote target (crane copy)
```

Seven services × two environments = fourteen repositories. Repositories use **IMMUTABLE** tags. Image tags follow the app workflow (`vX.Y.Z` stripped from `<service>-vX.Y.Z`); there is no `latest` tag.

## Status

ECR-only stacks. PR Terraform gates + manual apply on `main` via OIDC.
