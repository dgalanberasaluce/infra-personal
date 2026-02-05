resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
}

resource "aws_dynamodb_table" "t" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}