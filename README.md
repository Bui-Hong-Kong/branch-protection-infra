# branch-protection-infra

Terraform / infrastructure repo for the **branch-protection** lab (org `Bui-Hong-Kong`).

This repository holds **infrastructure-as-code only**. Application code lives in [`branch-protection`](https://github.com/Bui-Hong-Kong/branch-protection).

## Scope

| Area | Notes |
| --- | --- |
| ECR | One AWS account, two registries (`env-1`, `env-2`) |
| State | Remote: S3 + DynamoDB lock (created by `bootstrap/`) |
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

Do not commit secrets, access keys, or `bootstrap/terraform.tfvars`. `env/*.tfvars` only hold resource names. Prefer IAM roles / OIDC later for CI.

## Apply order

```text
aws sts get-caller-identity
  → bootstrap/          (local state, once)
  → repo root as env-1  (remote state)
  → repo root as env-2  (remote state)
```

### 1. Bootstrap remote state (once)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # edit if needed
terraform init
terraform apply
terraform output
```

Note the outputs: `state_bucket`, `lock_table`, `region`, `github_actions_role_arn`. The bucket and table must match `env-1.conf` and `env-2.conf`. Put `github_actions_role_arn` in the GitHub variable `AWS_ROLE_ARN` (a variable, not a secret). The role can only be assumed by `Bui-Hong-Kong/branch-protection-infra` on `refs/heads/main`.

Bootstrap uses **local state** (gitignored). Keep that state file safe or re-import later if lost.

### 2. Environment stack (ECR only)

From the repo root, one environment at a time:

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
| Where are secrets stored? | Not in this repo — AWS CLI / IAM / future CI OIDC |
| Who can access? | Org members with repo access + least-privilege cloud roles |
| Rotation / revocation | Rotate cloud credentials and CI tokens out-of-band |
| Committed to git? | **No** — never commit real secrets or `*.tfstate` |
| State bucket | Private, SSE, versioning, block public access (see `bootstrap/`) |

## Status

ECR-only scaffold. Compute and CI `terraform apply` workflows come later.
