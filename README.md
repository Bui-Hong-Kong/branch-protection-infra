# branch-protection-infra

Terraform / infrastructure repo for the **branch-protection** lab (org `Bui-Hong-Kong`).

This repository holds **infrastructure-as-code only**. Application code lives in [`branch-protection`](https://github.com/Bui-Hong-Kong/branch-protection).

## Scope

| Area | Notes |
| --- | --- |
| ECR | One AWS account, two registries (`env-1`, `env-2`) |
| State | Remote: S3 bucket and S3 lockfile (bucket created by `bootstrap/`) |
| Image flow | Build/push to env-1; copy to env-2 later (e.g. `crane`) — no compute yet |
| Compute | ECS / other runtimes — add later |

## Layout

```text
.
├── README.md
├── .gitignore
├── bootstrap/                     # one-time: state backend + GitHub Actions IAM role (local state)
├── main.tf                        # provider, empty S3 backend, ECR module
├── variables.tf
├── outputs.tf
├── versions.tf
├── env-1.conf                     # backend-config for env-1
├── env-2.conf                     # backend-config for env-2
├── env/
│   ├── env-1.tfvars
│   └── env-2.tfvars
└── modules/services/ecr/          # reusable ECR repository
```

One root serves both environments. Switch env by re-init with the other `.conf` and `-var-file`. `bootstrap/` stays a separate root.

## Prerequisites

- Terraform `1.15.7`
- AWS CLI configured for the **correct account** (`aws sts get-caller-identity`)
- Default region: `ap-southeast-1`

Do not commit secrets, access keys, or `bootstrap/terraform.tfvars`. `env/*.tfvars` only hold resource names. CI assumes the OIDC role created by `bootstrap/`; there is no GitHub Actions workflow in this repo yet.

## Apply order

Env-1 and env-2 share one root and stay in separate state files. One `apply` writes one state. Apply env-1, then re-init for env-2.

```text
aws sts get-caller-identity
  → bootstrap/          (local state, once)
  → repo root as env-1  (branch-protection/env-1/terraform.tfstate)
  → repo root as env-2  (branch-protection/env-2/terraform.tfstate)
```

### 1. Bootstrap remote state (once)

Defaults are `ap-southeast-1` and `name_prefix = branch-protection`. Copy `terraform.tfvars.example` only when changing those.

```bash
cd bootstrap
terraform init
terraform apply
terraform output
cd ..
```

`env-1.conf` and `env-2.conf` are already filled for account `975305815837` and lock state with `use_lockfile`. If `state_bucket` differs, edit the bucket in both `.conf` files before the next step.

`github_actions_role_arn` is for Terraform in this repo. Put it in the GitHub variable `AWS_ROLE_ARN` on `branch-protection-infra` (a variable, not a secret). The role can only be assumed by that repo on `refs/heads/main`.

`ecr_push_role_arn` and `ecr_copy_role_arn` belong on the app repo `branch-protection`. Push may only write `branch-protection-env-1` from `main`. Copy may read env-1 and write env-2, and only from GitHub Environment `env-2`.

Both GitHub repos use immutable OIDC subjects (`repo:OWNER@OWNER_ID/REPO@REPO_ID:...`). Trust policies in `bootstrap/iam.tf` match that format.

Bootstrap uses **local state** (gitignored). Keep that state file safe or re-import later if lost.

### 2. Environment stack (ECR only)

Run this from the repo root, one environment at a time. `cd ..` above returns here after bootstrap.

```bash
terraform init -backend-config=env-1.conf
terraform plan -var-file=env/env-1.tfvars
terraform apply -var-file=env/env-1.tfvars
```

Then switch to env-2. `-reconfigure` is required because this directory already has a backend:

```bash
terraform init -reconfigure -backend-config=env-2.conf
terraform plan -var-file=env/env-2.tfvars
terraform apply -var-file=env/env-2.tfvars
```

Optional: set `allowed_account_ids` in the env `.tfvars` to block apply against the wrong account.

## Security check

| Question | Answer |
| --- | --- |
| Where are secrets stored? | Not in this repo — AWS CLI locally, OIDC role from `bootstrap/` for CI |
| Who can access? | Org members with repo access + least-privilege cloud roles |
| Rotation / revocation | Rotate cloud credentials and CI tokens out-of-band |
| Committed to git? | **No** — never commit real secrets or `*.tfstate` |
| State bucket | Private, SSE, versioning, block public access (see `bootstrap/`) |

## Status

ECR-only scaffold. Compute and CI `terraform apply` workflows come later.
