data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# resource "aws_instance" "master" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = "t3.micro"
#   key_name                    = var.key-name
#   subnet_id                   = aws_subnet.public-subnet.id
#   vpc_security_group_ids      = [aws_security_group.security-group.id]
#   iam_instance_profile        = aws_iam_instance_profile.instance-profile.name

#   tags = {
#     Name = var.master
#   }
# }

# resource "aws_instance" "worker1" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = "t3.micro"
#   key_name                    = var.key-name
#   subnet_id                   = aws_subnet.public-subnet.id
#   vpc_security_group_ids      = [aws_security_group.security-group.id]
#   iam_instance_profile        = aws_iam_instance_profile.instance-profile.name

#   tags = {
#     Name = var.worker1
#   }
# }

# resource "aws_instance" "worker2" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = "t3.micro"
#   key_name                    = var.key-name
#   subnet_id                   = aws_subnet.public-subnet.id
#   vpc_security_group_ids      = [aws_security_group.security-group.id]
#   iam_instance_profile        = aws_iam_instance_profile.instance-profile.name

#   tags = {
#     Name = var.worker2
#   }
# }

resource "aws_instance" "ec2" {
  for_each = local.ec2_instances
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = var.key-name
  subnet_id = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.security-group.id]
  iam_instance_profile = aws_iam_instance_profile.instance-profile.name
  user_data = templatefile("scripts/setup.sh", {})
  tags = {
    Name = each.value
    Role = each.key
  }
}