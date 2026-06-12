module "tags" {
  source       = "../../modules/terraform-tags"
  env_name     = var.environment
  project_name = var.project
  region_name  = var.region
}

module "vpc" {
  source                     = "../../modules/network"
  tags                       = module.tags.common_tags
  vpc_cidr                   = "10.0.0.0/16"
  azs                        = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs        = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs       = ["10.0.11.0/24", "10.0.12.0/24"]
  cloudwatch_log_group_arn   = module.cloudwatch.vpc_flow_logs_cloudwatch_loggroup_arn
  vpc_flow_logs_iam_role_arn = module.iam.vpc_flow_logs_iam_role_arn
  cluster_name               = module.eks.cluster_name
  sg_eks_nodes_id            = module.eks.eks_worker_nodes_sg_id
  oidc_issuer_url            = module.eks.oidc_issuer_url
}

module "security_groups" {
  source     = "../../modules/security_group"
  tags       = module.tags.common_tags
  eks_vpc_id = module.vpc.vpc_id
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"
  tags   = module.tags.common_tags
}

module "iam" {
  source            = "../../modules/IAM"
  tags              = module.tags.common_tags
  vpc_flow_logs_arn = module.cloudwatch.vpc_flow_logs_cloudwatch_loggroup_arn
}

module "eks" {
  source             = "../../modules/eks"
  tags               = module.tags.common_tags
  kms_key_arn        = module.cloudwatch.kms_key_arn
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_vpc_id         = module.vpc.vpc_id
}

module "argocd" {
  source = "../../modules/argocd"
  tags   = module.tags.common_tags
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "alb_ingress" {
  source            = "../../modules/alb-ingress"
  tags              = module.tags.common_tags
  cluster_name      = module.eks.cluster_name
  oidc_issuer_url   = module.eks.oidc_issuer_url
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id
}