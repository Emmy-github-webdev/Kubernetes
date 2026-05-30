module "tags" {
  source = "../../modules/terraform-tags"
  env_name = var.env_name
  project_name = var.project_name
  region_name = var.region_name
}

module "vpc" {
  source = "../../modules/network"
  tags = module.tags.tags
  vpc_cidr = "10.0.0.0/16"
}