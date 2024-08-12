# data.tf contains all Terraform data source blocks (https://www.terraform.io/language/data-sources).

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/vpc_id"
}