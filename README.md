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
├── bootstrap/                 # one-time: S3 state bucket + DynamoDB lock (local state)
├── modules/ecr/               # reusable ECR repository
└── environments/
    ├── env-1/                 # remote state → branch-protection-env-1
    └── env-2/                 # remote state → branch-protection-env-2
```

## Prerequisites

- Terraform `>= 1.5`
- AWS CLI configured for the **correct account** (`aws sts get-caller-identity`)
- Default region: `ap-southeast-1`

Do not commit secrets, access keys, or real `*.tfvars`. Prefer IAM roles / OIDC later for CI.

## Apply order

```text
aws sts get-caller-identity
  → bootstrap/   (local state)
  → environments/env-1  (remote state)
  → environments/env-2  (remote state)
```

### 1. Bootstrap remote state (once)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # edit if needed
terraform init
terraform apply
terraform output
```

Note the outputs: `state_bucket`, `lock_table`, `region`.

Bootstrap uses **local state** (gitignored). Keep that state file safe or re-import later if lost.

### 2. Environment stacks (ECR only)

From each environment directory:

```bash
cd environments/env-1
cp terraform.tfvars.example terraform.tfvars

terraform init \
  -backend-config="bucket=<state_bucket from bootstrap>" \
  -backend-config="key=branch-protection/env-1/terraform.tfstate" \
  -backend-config="region=<region>" \
  -backend-config="dynamodb_table=<lock_table from bootstrap>" \
  -backend-config="encrypt=true"

terraform plan
terraform apply
```

Repeat for `environments/env-2` with key `branch-protection/env-2/terraform.tfstate`.

Optional: set `allowed_account_ids` in `terraform.tfvars` to block apply against the wrong account.

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
