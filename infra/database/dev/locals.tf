locals {
  services = {
    order = {
      db = "orderdb"
    }

    user = {
      db = "userdb"
    }

    payment = {
      db = "paymentdb"
    }

    product = {
      db = "productdb"
    }
  }
}