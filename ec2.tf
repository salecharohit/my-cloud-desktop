######################## VARIABLES ########################

variable "instance_type" {
  description = "Instance Type of the EC2"
  type        = string
}

variable "vscode_password" {
  description = "Password to access the Code Server"
  type        = string
}

variable "create_ami" {
  description = "Create AMI of the instance"
  type        = bool
  default     = false
}

######################## DATA ########################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

######################## MAIN ########################
resource "aws_instance" "ide" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.ide.id
    device_index         = 0
  }

  root_block_device {
    volume_size = 50
  }

  # https://github.com/hashicorp/terraform-provider-aws/issues/29829
  # https://github.com/hashicorp/terraform/issues/32754
  # metadata_options {
  #   http_endpoint = "disabled"
  # }

  connection {
    user        = "ubuntu"
    type        = "ssh"
    host        = self.public_ip
    private_key = tls_private_key.ide.private_key_pem
  }

  provisioner "file" {
    source      = "ansible"
    destination = "/tmp/ansible"
  }

  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh ${var.vscode_password}",
    ]
  }

  tags = {
    "Name"            = var.key_name
    "Environment"     = var.environment
    terraform-managed = "true"
  }

  depends_on = [
    aws_key_pair.generated_key
  ]

}

# Optionally you can create an AMI out of the instance
# Comment Out when running Lab
# NOTE: This will get destroyed if Terraform Destroy is executed.
# If you wish to save it then manual copy needs to be done.

# resource "aws_ami_from_instance" "web-ide-ami" {
#   count              = var.create_ami ? 1 : 0
#   name               = "web-ide-ami"
#   source_instance_id = aws_instance.ide[0].id
# }

# output "web-ide-ami-id" {
#   value = aws_ami_from_instance.web-ide-ami[0].id
# }

######################## OUTPUTS ########################

output "server_ip" {
  value = aws_instance.ide.public_ip
}