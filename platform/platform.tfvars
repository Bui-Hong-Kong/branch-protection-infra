region          = "ap-southeast-1"
name_prefix     = "branch-protection"
vpc_cidr        = "10.40.0.0/16"
azs             = ["ap-southeast-1a", "ap-southeast-1b"]
cluster_version = "1.31"

# Overnight / idle: workers + NAT off. EKS API + RDS still bill (~$3/day).
# Morning: set enable_nat_gateway=true, node_desired_size=5, node_min_size=2 → apply platform
#          then: aws eks update-nodegroup-config ... desiredSize=5 (module may ignore desired)
enable_nat_gateway  = false
node_instance_types = ["t3.medium"]
node_desired_size   = 0
node_min_size       = 0
node_max_size       = 6

cluster_endpoint_public_access = true
