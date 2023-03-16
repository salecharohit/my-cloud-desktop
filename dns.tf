######################## VARIABLES ########################

variable "duckdns_hostname" {
  type        = string
  description = "Hostname Generated on https://www.duckdns.org/"
}

variable "duckdns_token" {
  type        = string
  description = "Token generated on DuckDNS https://www.duckdns.org/"
}

variable "email" {
  type        = string
  description = "Email address needed for LetsEncrypt notifications"
}

######################## DATA ########################

data "http" "duckdns" {
  url = "https://www.duckdns.org/update?domains=${var.duckdns_hostname}&token=${var.duckdns_token}&ip=${aws_instance.cloud-desktop.public_ip}"
}

######################## MAIN ########################

resource "time_sleep" "wait_for_dns_propogation" {
  depends_on = [data.http.duckdns]

  create_duration = "60s"
}

resource "terraform_data" "implement_ssl" {

  triggers_replace = aws_instance.cloud-desktop.id

  connection {
    user        = "ubuntu"
    type        = "ssh"
    host        = aws_instance.cloud-desktop.public_ip
    private_key = tls_private_key.ubuntu.private_key_pem
  }

  provisioner "file" {
    source      = "ssl.sh"
    destination = "/tmp/ssl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ssl.sh",
      "/tmp/ssl.sh ${var.duckdns_hostname} ${var.email}",
    ]
  }

  depends_on = [time_sleep.wait_for_dns_propogation,
  aws_instance.cloud-desktop]

}

######################## OUTPUTS ########################