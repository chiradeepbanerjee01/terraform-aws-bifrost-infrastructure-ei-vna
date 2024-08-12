# main.tf contains the main Terraform resource and module definitions.
# This may be split out appropriately into separate `*.tf` files and documented in README.md under a section titled "File Structure".
# If splitting out main.tf, .terraform-docs.yml must be updated. See the checklist in README.md for more information.

module "baselinevpc" {
  source = "git@github.com:HylandSoftware/terraform-aws-delivery-infra-service-catalog.git//aws_network_vpc?ref=3.0.0"
}

module "r53setup" {
  source    = "git@github.com:HylandSoftware/terraform-aws-delivery-infra-service-catalog.git//aws_network_route53_delegation?ref=3.0.0"
  zone_name = var.zone_name
  providers = {
    aws.awsns = aws.awsns
  }
}

module "acmcert" {
  source = "git@github.com:HylandSoftware/terraform-aws-delivery-infra-service-catalog.git//aws_security_acm_certificate?ref=3.0.0"

  depends_on = [
    module.r53setup
  ]
}


module "ecs_cluster" {
  source = "git@github.com:HylandSoftware/terraform-aws-delivery-infra-service-catalog.git//aws_compute_ecs_cluster?ref=3.0.0"
}

