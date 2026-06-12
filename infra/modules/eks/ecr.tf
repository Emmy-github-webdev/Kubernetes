resource "aws_ecr_repository" "eks_ecr_repository" {
  name                 = var.Ecr_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "eks_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.eks_ecr_repository.name

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