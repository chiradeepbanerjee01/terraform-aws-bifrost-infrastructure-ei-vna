# outputs.tf contains all Terraform output definitions (https://www.terraform.io/language/values/outputs).

output "dns_a_record" {
  value = module.ecs_service.dns_a_record
}
