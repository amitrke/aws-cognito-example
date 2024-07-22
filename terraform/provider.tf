provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      app_name = var.app_name
      managed_by = "terraform"
    }
  }
}