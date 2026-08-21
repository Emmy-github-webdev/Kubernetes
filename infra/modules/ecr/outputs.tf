output "ecr_repositories" {
  value = {
    for name, repo in aws_ecr_repository.eks_ecr_repository :
    name => {
      name = repo.name
      url  = repo.repository_url
      arn  = repo.arn
    }
  }
}

output "repository_urls" {
  description = "Shared ECR repository URLs keyed by service"
  value = {
    for name, repo in aws_ecr_repository.eks_ecr_repository :
    name => repo.repository_url
  }
}