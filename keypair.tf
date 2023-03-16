######################## VARIABLES ########################

variable "key_name" {
  description = "SSH Key Name For Authentication"
  type        = string
  default     = "ubuntu"
}

######################## MAIN ########################

resource "tls_private_key" "ubuntu" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ubuntu.public_key_openssh

}

######################## OUTPUT ########################

# # Write the Public Key to SSM Store
# module "ssmw-ssh-public-key" {
#   source                = "./modules/ssmw"
#   parameter_name        = "ssh_pub_key"
#   parameter_path        = "/cloud-desktop"
#   parameter_value       = base64encode(tls_private_key.ubuntu.public_key_openssh)
#   parameter_description = "SSH Public Key"
#   parameter_type        = "String"
#   environment           = var.environment
# }

# # Write the Private Key to SSM Store
# module "ssmw-ssh-private-key" {
#   source                = "./modules/ssmw"
#   parameter_name        = "ssh_private_key"
#   parameter_path        = "/cloud-desktop"
#   parameter_value       = base64encode(tls_private_key.ubuntu.private_key_pem)
#   parameter_description = "SSH Private Key"
#   parameter_type        = "SecureString"
#   environment           = var.environment
# }

resource "local_file" "ubuntu_key" {
  content         = tls_private_key.ubuntu.private_key_pem
  filename        = "ubuntu_key.pem"
  file_permission = "400"
}