# Create a VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name                         = "${var.user_name}-vpc"
  cidr                         = var.vpc_cidr
  enable_dns_hostnames         = true
  enable_dns_support           = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  enable_vpn_gateway           = false
  azs                          = var.availability_zones
  private_subnets              = var.private_subnets_cidr
  public_subnets               = var.public_subnets_cidr
  database_subnets             = var.database_subnets_cidr
  create_database_subnet_group = false

  tags = {
    "Name"            = "${var.user_name}-vpc"
    "Environment"     = var.environment
    terraform-managed = "true"
  }
}