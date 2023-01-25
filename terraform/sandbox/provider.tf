terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "= 4.48.0"
        }
    }
}

provider "aws" {
profile = "innovative_sandbox"
region  = "us-east-1"

  default_tags {
    tags = {
      Environment = "Test"
      Owner       = "JMason"
      CreatedBy   = "Terraform"
    }
  }
}
