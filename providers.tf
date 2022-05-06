terraform {
  required_version = ">= 0.12.9, != 0.13.0"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.7.1"
    }
    null  = ">= 3.0"
    local = ">= 2.0"
  }
}

provider "volterra" {
  api_cert = "files/certificate.cer"
  api_key  = "files/certificate.key"
  url      = var.api_url
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

