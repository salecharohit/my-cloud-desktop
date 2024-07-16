######################## VARIABLES ########################

variable "database_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
  default = [
    "10.0.21.0/24",
    "10.0.22.0/24",
    "10.0.23.0/24"
  ]
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "apply_source_ip_restriction" {
  description = "Whether to apply source IP restrictions. If true then IP from where terraform is being executed will be fetched. If False then a default all open CIDR will be applied"
  type        = string
}

variable "default_cidr" {
  description = "Default Internet wide CIDR"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

######################## DATA ########################

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

data "aws_availability_zones" "availability_zones" {}

######################## LOCALS ########################

locals {

  source_ip_allowed = var.apply_source_ip_restriction ? ["${chomp(data.http.ip.response_body)}/32"] : var.default_cidr

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = local.source_ip_allowed
      description = "SSH Service"
      type        = "ingress"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = local.source_ip_allowed
      description = "HTTPS over Caddy"
      type        = "ingress"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = local.source_ip_allowed
      description = "HTTP over Caddy"
      type        = "ingress"
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_block  = var.default_cidr
      description = "Port 53 for DNS Service"
      type        = "ingress"
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      cidr_block  = var.default_cidr
      description = "Port 53 for DNS Service"
      type        = "ingress"
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = var.default_cidr
      description = "Egress Service for communication outside"
      type        = "egress"
    }
  ]
}

######################## MAIN ########################

# Crate a VPC with all the associated network plumbing
module "networking" {
  source = "./modules/vpc"

  environment           = var.environment
  user_name             = var.key_name
  vpc_cidr              = var.vpc_cidr
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_cidr  = var.private_subnets_cidr
  database_subnets_cidr = var.database_subnets_cidr
  region                = var.region
  availability_zones    = data.aws_availability_zones.availability_zones.names

}

module "web-ide-ingress-rules" {
  source = "./modules/securitygroup"

  sg_name        = "${var.key_name}-web-ide-ingress-rules"
  sg_description = "All ingress rules required for web-ide desktop"
  environment    = var.environment
  vpc_id         = module.networking.vpc_id
  ingress_rules  = local.ingress_rules
  depends_on     = [module.networking]
}

resource "aws_network_interface" "ide" {
  subnet_id = module.networking.public_subnets_id[0]
  security_groups = [
    module.web-ide-ingress-rules.id
  ]

  tags = {
    Name = "${var.key_name}_network_interface"
  }
}

######################## OUTPUTS ########################