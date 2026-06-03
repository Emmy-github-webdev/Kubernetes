locals {
  env_name     = var.env_name
  project_name = var.project_name
  region_name  = var.region_name
}

locals {
  common_tags = {
    environment = local.env_name
    project     = local.project_name
    region      = local.region_name
  }
}