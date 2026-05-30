module "tags" {
  source       = "../../modules/terraform-tags"
  env_name     = var.environment
  project_name = var.project
  region_name  = var.region
}

module "vpc" {
  source   = "../../modules/network"
  tags     = module.tags.common_tags
  vpc_cidr = "10.0.0.0/16"
}