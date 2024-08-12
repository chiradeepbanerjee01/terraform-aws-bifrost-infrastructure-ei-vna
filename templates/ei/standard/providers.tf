# providers.tf contains all provider configuration blocks (https://www.terraform.io/language/providers/configuration).
provider "aws" {
  assume_role {
    role_arn = var.assume_role
  }
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

provider "aws" {
  alias = "awsns"
  assume_role {
    role_arn = "arn:aws:iam::962530257108:role/@delivery_org_r53_delegation"
  }
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}