resource "random_password" "order_db_password" {
  length  = 32
  special = true
}

resource "aws_db_subnet_group" "order" {

  name = "${var.tags.environment}-orderdb-subnet"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.tags.environment}-orderdb-subnet"
  }
}

resource "aws_security_group" "order_db" {

  name   = "${var.tags.environment}-orderdb-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "postgres_ingress" {

  type                     = "ingress"

  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"

  source_security_group_id = var.eks_node_security_group_id

  security_group_id        = aws_security_group.order_db.id
}

resource "aws_security_group_rule" "all_egress" {

  type              = "egress"

  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  security_group_id = aws_security_group.order_db.id
}

resource "aws_db_instance" "order" {

  identifier = "${var.tags.environment}-orderdb"

  engine         = "postgres"
  engine_version = "16.4"

  instance_class = "db.r6g.large"

  allocated_storage = 100

  storage_type = "gp3"

  storage_encrypted = true

  multi_az = true

  publicly_accessible = false

  db_name  = "orderdb"

  username = "${var.tags.environment}orderadmin"

  password = random_password.order_db_password.result

  backup_retention_period = 30

  deletion_protection = true

  skip_final_snapshot = false

  db_subnet_group_name = aws_db_subnet_group.order.name

  vpc_security_group_ids = [
    aws_security_group.order_db.id
  ]
}

resource "aws_secretsmanager_secret" "order_db" {

  name = "/${var.tags.environment}/order-service/database"

  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "order_db" {

  secret_id = aws_secretsmanager_secret.order_db.id

  secret_string = jsonencode({
    host     = aws_db_instance.order.address
    port     = 5432
    dbname   = "orderdb"
    username = "${var.tags.environment}orderadmin"
    password = random_password.order_db_password.result
  })
}

data "aws_iam_policy_document" "assume_role" {

  statement {

    actions = ["sts:AssumeRoleWithWebIdentity"]

    effect = "Allow"

    principals {

      type = "Federated"

      identifiers = [
        var.eks_oidc_provider_arn
      ]
    }

    condition {

      test = "StringEquals"

      variable = "${replace(var.eks_oidc_provider_url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:orders:order-service"
      ]
    }
  }
}

resource "aws_iam_role" "order_service" {

  name = "${var.tags.environment}-order-service-irsa"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "order_secret_access" {

  name = "${var.tags.environment}-order-secret-access"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = aws_secretsmanager_secret.order_db.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {

  role       = aws_iam_role.order_service.name

  policy_arn = aws_iam_policy.order_secret_access.arn
}