region          = "ap-southeast-1"
name_prefix     = "branch-protection"
vpc_cidr        = "10.40.0.0/16"
azs             = ["ap-southeast-1a", "ap-southeast-1b"]
cluster_version = "1.31"

node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3

cluster_endpoint_public_access = true
