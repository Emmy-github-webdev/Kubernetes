locals {
  ec2_instances = {
    "master" = var.master
    "worker1" = var.worker1
    "worker2" = var.worker2
  }
}