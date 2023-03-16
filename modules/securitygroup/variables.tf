variable "sg_name" {
  description = "Name of the Security group"
  type        = string
}

variable "sg_description" {
  description = "Description of the Security Group"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment to be installed"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ingress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      type    = string
      cidr_block  = list(string)
      description = string
    }))
}








