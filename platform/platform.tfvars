region          = "ap-southeast-1"
name_prefix     = "branch-protection"
vpc_cidr        = "10.40.0.0/16"
azs             = ["ap-southeast-1a", "ap-southeast-1b"]
cluster_version = "1.31"

# ~12 pods/env × DEV+UAT+PROD + system (Argo/ALB/CoreDNS). t3.medium ≈ 17 pods/node.
node_instance_types = ["t3.medium"]
node_desired_size   = 5
node_min_size       = 2
node_max_size       = 6

cluster_endpoint_public_access = true
