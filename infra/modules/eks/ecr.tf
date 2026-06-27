locals {
  services = [
    "user-service",
    "order-service",
    "payment-service",
    "product-service"
  ]
  repository_prefix = var.app_name
}

resource "aws_ecr_repository" "eks_ecr_repository" {
  for_each             = toset(local.services)
  name                 = "${local.repository_prefix}/${each.value}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  force_delete = true
  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "eks_ecr_lifecycle_policy" {
  for_each = aws_ecr_repository.eks_ecr_repository

  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1

      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 50
      }

      action = {
        type = "expire"
      }
    }]
  })
}