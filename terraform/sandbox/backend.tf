# For new accounts copy this file to the new account's
# folder and only update the key value

terraform {

  required_version = ">= 1.3.1"

  backend "s3" {
    bucket         = "starktech-us-gov-east-terraform-bucket"
    key            = "prod/us-gov-east/terraform.tfstate"
    kms_key_id     = "arn:aws-us-gov:kms:us-gov-east-1:077322660848:key/7b5ac662-3105-4ad7-bb3c-8ef8bcc0dd46"
    region         = "us-gov-east-1"
    encrypt        = true
    dynamodb_table = "starktech-us-gov-east-terraform"
    profile        = "starktech-gov"
  }
}