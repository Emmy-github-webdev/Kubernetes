module "tags" {
  source = "../../modules/tags"
  env_name = var.env_name
  project_name = var.project_name
  region_name = var.region_name
}

module "vpc" {
  source = "../../modules/vpc"
  tags = module.tags.tags
  vpc_cidr = "10.0.0.0/16"
}