resource "helm_release" "argocd" {
  name             = "${var.tags.project}-${var.tags.environment}-argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true

}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  version = "1.18.0"

  values = [
    yamlencode({
      provider = "aws"

      policy     = "upsert-only"
      registry   = "txt"
      txtOwnerId = var.cluster_name

      serviceAccount = {
        create = true
        name   = "external-dns"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
        }
      }

      sources = [
        "service",
        "ingress",
      ]
    })
  ]
}

# External secrets IAM role and policy
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "external_secrets" {

  name = "external-secrets-${var.tags.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {

          StringEquals = {

            "${replace(
              data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer,
              "https://",
              ""
            )}:aud" = "sts.amazonaws.com"

            "${replace(
              data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer,
              "https://",
              ""
            )}:sub" = "system:serviceaccount:external-secrets:external-secrets-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "external_secrets" {

  role = aws_iam_role.external_secrets.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "external_dns" {
  name = "external-dns-${var.tags.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(
              data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer,
              "https://",
              ""
            )}:aud" = "sts.amazonaws.com"

            "${replace(
              data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer,
              "https://",
              ""
            )}:sub" = "system:serviceaccount:external-dns:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "external_dns" {
  role = aws_iam_role.external_dns.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "route53:ChangeResourceRecordSets"
        ]

        Resource = [
          "arn:aws:route53:::hostedzone/<HOSTED_ZONE_ID>"
        ]
      },
      {
        Effect = "Allow"

        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "88.0.1"
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.18.2"

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

resource "helm_release" "kyverno" {
  name             = "kyverno"
  namespace        = "kyverno"
  create_namespace = true

  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
}

resource "helm_release" "velero" {
  name             = "velero"
  namespace        = "velero"
  create_namespace = true

  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = "11.1.1"

  set {
    name  = "serviceAccount.server.name"
    value = "velero"
  }

  set {
    name  = "serviceAccount.server.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.velero.arn
  }

  set {
    name  = "serviceAccount.server.create"
    value = "true"
  }

  set {
    name  = "configuration.backupStorageLocation[0].name"
    value = "default"
  }

  set {
    name  = "configuration.backupStorageLocation[0].provider"
    value = "aws"
  }

  set {
    name  = "configuration.volumeSnapshotLocation[0].name"
    value = "default"
  }

  set {
    name  = "configuration.volumeSnapshotLocation[0].provider"
    value = "aws"
  }

  set {
    name  = "configuration.backupStorageLocation[0].config.region"
    value = var.tags.region
  }

  set {
    name  = "configuration.backupStorageLocation[0].bucket"
    value = aws_s3_bucket.velero.id
  }

  set {
    name  = "configuration.volumeSnapshotLocation[0].config.region"
    value = var.tags.region
  }


  depends_on = [
    aws_iam_role_policy_attachment.velero,
    helm_release.snapshot_controller
  ]

}

resource "aws_iam_policy" "velero" {
  name = "${var.tags.project}-${var.tags.environment}-velero-backup-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ]
        Resource = "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "velero_assume_role" {

  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      identifiers = [
        var.oidc_provider_arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test = "StringEquals"

      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:velero:velero"
      ]
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "velero" {
  bucket = "${var.tags.project}-${var.tags.environment}-${data.aws_caller_identity.current.account_id}-velero-backups"
}

resource "aws_iam_role" "velero" {
  name = "${var.tags.project}-${var.tags.environment}-velero"

  assume_role_policy = data.aws_iam_policy_document.velero_assume_role.json
}

resource "aws_iam_role_policy_attachment" "velero" {

  role = aws_iam_role.velero.name

  policy_arn = aws_iam_policy.velero.arn
}

resource "helm_release" "metrics_server" {
  name      = "metrics-server"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
}

resource "helm_release" "snapshot_controller" {
  name             = "${var.tags.project}-${var.tags.environment}-snapshot-controller"
  namespace        = "kube-system"
  create_namespace = false

  repository = "https://piraeus.io/helm-charts/"
  chart      = "snapshot-controller"

  version = "5.1.1"
}