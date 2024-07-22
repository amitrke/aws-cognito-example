# Create a DynamoDB table for the application
resource "aws_dynamodb_table" "this" {
  name           = var.app_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }

  deletion_protection_enabled = false
}