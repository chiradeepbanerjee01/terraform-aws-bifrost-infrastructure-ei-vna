# main.tf contains the main Terraform resource and module definitions.

module "baselinevpc" {
  source = "git@github.com:HylandSoftware/terraform-aws-delivery-infra-service-catalog.git//aws_network_vpc?ref=3.0.0"
}

module "managedad" {
  source = "git@github.com:HylandSoftware/terraform-aws-delivery-infra-service-catalog.git//aws_security_directory_services?ref=3.0.0"
  depends_on = [
    module.baselinevpc #managed AD requires subnets to deploy the domain controllers into
  ]
}

module "winfsx" {
  source = "git@github.com:HylandSoftware/terraform-aws-delivery-infra-service-catalog.git//aws_datapersistence_fsx_windows?ref=3.0.0"
  depends_on = [
    module.baselinevpc, #FSX requires a subnet to place the FSX endpoint in
    module.managedad    #This code assumes the windows FSX is attaching itself to the managed AD
  ]
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
    module.r53setup #ACM performs DNS validation that requires the zone delegation to be in place to succeed
  ]
}

module "arcus_ssm_document" {
  source = "git@github.com:HylandSoftware/terraform-aws-delivery-infra-service-catalog.git//aws_systemsmanager_arcus_client?ref=3.0.0"
}

module "waf_log_group" {
  source = "git@github.com:HylandSoftware/terraform-aws-delivery-infra-service-catalog.git//aws_observability_cloudwatch_log_group?ref=3.0.0"
}
