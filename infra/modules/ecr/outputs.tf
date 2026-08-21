output "repository_url" {
  value = {
    for k, repo in aws_ecr_repository.eks_ecr_repository :
    k => repo.repository_url
  }
}