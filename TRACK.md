# Track B — Full multi-env lab (EKS × 3 namespaces)

This repository is **only Track B**. It is the higher-cost GitOps path (shared cluster, three envs).

## Goal

| Piece | Choice |
| --- | --- |
| Compute | 1 VPC + 1 EKS |
| Environments | Namespaces `sockshop-dev` / `sockshop-uat` / `sockshop-prod` |
| Images | ECR `sockshop-<service>-env-1/2/3` + promote |
| Catalogue | RDS MySQL + logical DBs `socksdb_dev` / `socksdb_uat` / `socksdb_prod` |
| Other data | Mongo + Rabbit **per namespace** (in-cluster) |
| GitOps | Argo CD + Helm Applications in app repo `deploy/` |

## Out of scope (Track A)

- Single EC2 + Docker Compose as primary runtime
- “Cheap idle = stop one VM” as the main cost story (here: idle nodes + NAT; EKS control plane still bills)

→ Use [`sockshop-ec2-lab`](https://github.com/Bui-Hong-Kong/sockshop-ec2-lab) (**Track A**).

## App repo wiring

| Concern | Location in `branch-protection` |
| --- | --- |
| Helm + Argo Apps | `deploy/helm`, `deploy/argocd` |
| Image promote | `.github/workflows/04–06-*` |
| Flyway (still valid against RDS) | `backend/catalogue/flyway` — run **per DB name** for three envs |

## Cost warning

EKS control plane + NAT + nodes + ALBs dominate spend. Prefer Track A for daily practice; use Track B for multi-env / GitOps drills, then idle or destroy.
