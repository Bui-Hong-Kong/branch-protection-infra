# branch-protection-infra

Terraform / infrastructure repo for the **branch-protection** lab (org `Bui-Hong-Kong`).

This repository is intended to hold **infrastructure-as-code only** (for example AWS ECR and related IAM). Application code lives in [`branch-protection`](https://github.com/Bui-Hong-Kong/branch-protection).

## Scope (planned)

| Area | Notes |
| --- | --- |
| ECR | Registries per environment (e.g. env-1, env-2) |
| Image flow | Build/push to env-1; copy to env-2 (e.g. with `crane`) — no compute deploy in the first phase |
| Compute | ECS / other runtimes — add later |

## Layout (to be added)

```text
.
├── README.md
├── environments/          # env-1, env-2 (or workspaces)
├── modules/               # reusable Terraform modules
└── versions.tf            # provider / terraform version constraints
```

Do not commit secrets, access keys, or `.tfvars` with real credentials. Prefer CI OIDC / IAM roles and remote state with controlled access.

## Security check

| Question | Answer |
| --- | --- |
| Where are secrets stored? | Not in this repo — use CI secrets / cloud IAM / secret manager |
| Who can access? | Org members with repo access + least-privilege cloud roles |
| Rotation / revocation | Rotate cloud credentials and CI tokens out-of-band |
| Committed to git? | **No** — never commit real secrets |

## Status

Scaffold only. Terraform modules and environment configs will be added in follow-up PRs.
