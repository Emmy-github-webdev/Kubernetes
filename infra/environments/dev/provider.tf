terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate)
  token                  = data.aws_eks_auth.cluster.token
}

data "aws_eks_auth" "cluster" {
  name = module.eks.cluster_name
}