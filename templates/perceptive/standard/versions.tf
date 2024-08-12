# versions.tf contains the Terraform configuration block (https://www.terraform.io/language/settings).

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
   backend "s3" {
    bucket         = "terraform-remote-state-<<ACCOUNT_NUMBER>>-us-east-2"
    key            = "KEYGOESHERE"
    region         = "us-east-2"
    dynamodb_table = "terraform-remote-state-<<ACCOUNT_NUMBER>>-us-east-2"
    profile        = "default"
  }
}
