# --------------------------------------------------------------------------------------------------
# Backend
# --------------------------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "your-tf-backend-bucket"
    key    = "jenkins"
    region = "eu-west-1"
  }
}