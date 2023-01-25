terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "= 4.48.0"
        }
    }
}

provider "aws" {
profile = "starktech-gov"
region  = "us-gov-east-1"

  default_tags {
    tags = {
      Environment = "Production"
      Owner       = "StarkTech"
      CreatedBy   = "Terraform"
    }
  }
}
