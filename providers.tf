# Setting and locking the Dependencies to specific versions
terraform {
  required_providers {

    # AWS Cloud Provider
    aws = {
      source  = "hashicorp/aws"
      version = "4.54"
    }

    # TLS provider to generate SSH Keys
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    # Provider to generate random numbers
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    # Provider to interact with the local system
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }

  }
  # Setting the Terraform version
  required_version = ">= 1.4.0"
}

# Default provider
provider "aws" {
  region = var.region
}
