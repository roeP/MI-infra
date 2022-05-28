resource "aws_ecr_repository" "MI" {
  name                 = "MI"

  image_scanning_configuration {
    scan_on_push = false
  }
}