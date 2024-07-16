######################## VARIABLES ########################

variable "hostname" {
  type        = string
  description = "The FQDN configured as Route53 Zone"
}

######################## DATA ########################

# Fetch the Zone ID of the hosted domains
data "aws_route53_zone" "domain" {
  name = "${var.hostname}."

}

######################## MAIN ########################

resource "aws_route53_record" "ide" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.hostname}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.ide.public_ip]
}

resource "time_sleep" "wait_for_dns_propogation" {
  depends_on = [aws_route53_record.ide]

  create_duration = "60s"
}

resource "terraform_data" "implement_ssl" {

  triggers_replace = aws_instance.ide.id

  connection {
    user        = "ubuntu"
    type        = "ssh"
    host        = aws_instance.ide.public_ip
    private_key = tls_private_key.ide.private_key_pem
  }

  provisioner "file" {
    source      = "ssl.sh"
    destination = "/tmp/ssl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ssl.sh",
      "/tmp/ssl.sh ${var.hostname}",
    ]
  }

  depends_on = [time_sleep.wait_for_dns_propogation,
  aws_instance.ide]

}

######################## OUTPUTS ########################