variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
}

variable "environment" {
  description = "The Deployment environment"
  type        = string
}

variable "user_name" {
  description = "username"
  type        = string
}

variable "database_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  type        = string
}