variable "env_name" {
  description = "Defines the environment to provision the resurces"
  type        = string
}

variable "project_name" {
  description = "Defines the project name"
  type        = string
}

variable "region_name" {
  type        = string
  description = "Defines the region where the resources are created"
}