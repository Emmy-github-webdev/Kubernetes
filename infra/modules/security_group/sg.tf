# Restrict default security group to deny all traffic
resource "aws_default_security_group" "default" {
  vpc_id = var.eks_vpc_id

  # Completely restrict all inbound traffic
  ingress = []

  # Completely restrict all outbound traffic  
  egress = []

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-default-sg"
  }
}