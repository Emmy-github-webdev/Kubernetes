output "ecr_repository_urls" {
  value = {
    user-service = module.ecr.repository_urls["user-service"]
    payment-service = module.ecr.repository_urls["payment-service"]
    product-service = module.ecr.repository_urls["product-service"]
    order-service = module.ecr.repository_urls["order-service"]
  }
}