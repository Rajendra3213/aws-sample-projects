resource "aws_dynamodb_table" "table" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ID"
  range_key      = "FirstName"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "FirstName"
    type = "S"
  }

  tags = var.tags
}