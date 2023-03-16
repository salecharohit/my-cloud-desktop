# AWS Security Group definition
resource "aws_security_group" "security_group" {
  name_prefix = "${var.sg_name}-"
  vpc_id      = var.vpc_id
  description = var.sg_description
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Environment"     = var.environment
    terraform-managed = "true"
  }
}

# AWS Security Group Rules definitions
resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_rules)

  type              = var.ingress_rules[count.index].type
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_block
  description       = var.ingress_rules[count.index].description
  security_group_id = aws_security_group.security_group.id
}