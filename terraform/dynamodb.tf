#Deprecated
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

#Event Table
resource "aws_dynamodb_table" "events" {
  name           = "${var.app_name}-events"
  billing_mode   = "PAY_PER_REQUEST"
  
  hash_key = "UserId"
  range_key = "SortKey"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "SortKey"
    type = "S"
  }

  global_secondary_index {
    name               = "SortKeyIndex"
    hash_key           = "SortKey"
    range_key          = "UserId"
    projection_type    = "KEYS_ONLY"
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  deletion_protection_enabled = false
}

#EventsV2 Table
resource "aws_dynamodb_table" "eventsV2" {
  name           = "${var.app_name}-eventsV2"
  billing_mode   = "PAY_PER_REQUEST"
  
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }
  
  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    projection_type = "ALL"
    read_capacity   = 5
    write_capacity  = 5
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  deletion_protection_enabled = false
}