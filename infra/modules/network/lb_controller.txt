# Retrieve TLS certificate from the OIDC issuer
data "tls_certificate" "eks_oidc" {
  url = var.oidc_issuer_url
}

# Create IAM OIDC Provider
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url = var.oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]
}

# IRSA (IAM Roles for Service Accounts)
data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:aud"

      values = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "irsa_role" {
  name               = "${var.tags.project}-${var.tags.environment}-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}