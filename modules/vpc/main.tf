data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name            = var.vpc_name
  cidr            = var.vpc_cidr_block
  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets


  database_subnets                       = var.vpc_database_subnets
  create_database_subnet_group           = var.vpc_create_database_subnet_group
  create_database_subnet_route_table     = var.vpc_create_database_subnet_route_table
  database_subnet_group_name             = var.vpc_database_subnet_group_name
  create_database_internet_gateway_route = false
  create_database_nat_gateway_route      = false

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags     = var.common_tags
  vpc_tags = var.common_tags

  public_subnet_tags = {
    Type                                            = "Public Subnets"
    "kubernetes.io/role/elb"                        = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
  private_subnet_tags = {
    Type                                            = "private-subnets"
    "kubernetes.io/role/internal-elb"               = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  database_subnet_tags = {
    Type = "database-subnets"
  }
  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true
}
