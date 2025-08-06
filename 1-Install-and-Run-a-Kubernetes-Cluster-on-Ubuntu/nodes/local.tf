locals {
  ec2_instances = {
    "master"  = { name = var.master,  hostname = var.master }
    "worker1" = { name = var.worker1, hostname = var.worker1 }
    "worker2" = { name = var.worker2, hostname = var.worker2 }
  }
}
