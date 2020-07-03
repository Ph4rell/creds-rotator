terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region      = "eu-west-1"
}

resource "aws_ses_email_identity" "example" {
  email = var.email
}