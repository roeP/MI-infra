resource "aws_ecr_repository" "MI" {
  name                 = "var.ecr_name"

  image_scanning_configuration {
    scan_on_push = false
  }
}