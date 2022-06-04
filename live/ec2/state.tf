terraform {
  backend "s3" {
    bucket = "mi-terraform-state-bucket"
    region = "us-east-1"
    key = "ec2.state"
  }
}