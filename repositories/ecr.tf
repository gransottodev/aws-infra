resource "aws_ecr_repository" "products_service" {
  name = "products-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "products_service_url" {
  value = aws_ecr_repository.products_service.repository_url
}