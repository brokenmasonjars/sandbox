# For new accounts copy this file to the new account's
# folder and only update the key value

terraform {

  required_version = ">= 1.3.1"

  backend "s3" {
    bucket         = "jmason-idps-sandbox-bucket"
    key            = "terraform.tfstate"
    kms_key_id     = "arn:aws:kms:us-east-1:141388277701:key/4b899881-86a4-4f2d-8879-988590d83b19"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "jmason-idps-sandbox-dynamodb"
    profile        = "innovative_sandbox"
  }
}