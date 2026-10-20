module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.21"

  name = "${var.name_prefix}-platform"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 4, i + 8)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Required for AWS Load Balancer Controller subnet discovery.
  public_subnet_tags = {
    "kubernetes.io/role/elb"                       = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
  }

  tags = {
    Name      = "${var.name_prefix}-platform"
    Component = "network"
  }
}
